# frozen_string_literal: true

require 'googleauth'
require 'google/apis/sheets_v4'
require_relative 'google_sheets_client'
require_relative 'alg_extractor'
require_relative 'sheet_filter'

module CubeTrainer
  module SheetScraping
    # Client that scrapes alg sets from Google sheets.
    class GoogleSheetsScraper
      def initialize(
        credentials_factory: Google::Auth::ServiceAccountCredentials,
        sheets_service_factory: Google::Apis::SheetsV4::SheetsService,
        sheet_filter: AllSheetFilter.new
      )
        @sheets_client = GoogleSheetsClient.new(
          credentials_factory: credentials_factory,
          sheets_service_factory: sheets_service_factory,
          sheet_filter: sheet_filter
        )
        @sheet_filter = sheet_filter
      end

      def run
        @sheets_client.fetch_access_token!
        AlgSpreadsheet.all.filter_map do |alg_spreadsheet|
          next unless @sheet_filter.spreadsheet_owner_passes?(alg_spreadsheet.owner)

          scrape_sheet(alg_spreadsheet)
        end
      end

      def scrape_sheet(alg_spreadsheet)
        Rails.logger.info "Scraping #{alg_spreadsheet.spreadsheet_id} by #{alg_spreadsheet.owner}."
        tables = @sheets_client.get_tables(alg_spreadsheet.spreadsheet_id)
        Rails.logger.info "Got #{tables.length} sheets " \
                          "with a total of #{total_cells(tables)} cells."
        counters = new_counters
        tables.map { |t| extract_alg_set(alg_spreadsheet, t, counters) }
        log_counters(counters)
        counters
      end

      private

      def new_counters
        {
          updated_algs: 0,
          new_algs: 0,
          confirmed_algs: 0,
          correct_algs: 0,
          fixed_algs: 0,
          unfixable_algs: 0,
          unparseable_algs: 0
        }
      end

      def log_counters(counters)
        Rails.logger.info "Got #{counters[:new_algs]} new algs, " \
                          "updated #{counters[:updated_algs]} algs " \
                          "and confirmed #{counters[:confirmed_algs]} algs."
        Rails.logger.info "Got #{counters[:correct_algs]} correct algs, " \
                          "#{counters[:fixed_algs]} fixed algs " \
                          "#{counters[:unfixable_algs]} unfixable algs " \
                          "and #{counters[:unparseable_algs]} unparseable algs."
      end

      def add_counters(extracted_alg_set, counters)
        counters[:correct_algs] += extracted_alg_set.algs.length
        counters[:fixed_algs] += extracted_alg_set.fixes.length
        counters[:unfixable_algs] += extracted_alg_set.num_unfixable
        counters[:unparseable_algs] += extracted_alg_set.num_unparseable
      end

      def find_or_create_alg_set(alg_spreadsheet, extracted_alg_set, table)
        alg_spreadsheet.alg_sets.find_or_create_by!(
          case_set: extracted_alg_set.case_set,
          sheet_title: table.sheet_info.title
        )
      end

      def extract_alg_set(alg_spreadsheet, table, counters)
        extracted_alg_set = AlgExtractor.extract_alg_set(table) || return
        add_counters(extracted_alg_set, counters)
        alg_set = find_or_create_alg_set(alg_spreadsheet, extracted_alg_set, table)
        extracted_alg_set.algs.each do |casee, alg|
          save_alg(alg_set, casee, alg, counters)
        end
        extracted_alg_set.fixes.each do |fix|
          save_alg(
            alg_set, fix.casee, fix.fixed_algorithm, counters,
            is_fixed: true
          )
        end
      end

      def save_alg(alg_set, casee, alg, counters, is_fixed: false)
        existing_alg = alg_set.algs.find_by(casee: casee)
        return update_alg(existing_alg, alg, counters, is_fixed: is_fixed) if existing_alg

        create_new_alg(alg_set, casee, alg, counters, is_fixed: is_fixed)
      end

      def create_new_alg(alg_set, casee, alg, counters, is_fixed:)
        counters[:new_algs] += 1
        alg_model = alg_set.algs.new(
          casee: casee,
          alg: alg,
          is_fixed: is_fixed
        )
        return if alg_model.save

        Rails.logger.error "Error creating alg #{alg} for case #{casee}:\n" \
                           "#{alg_model.errors.full_messages.join('\n')}"
      end

      def update_alg(existing_alg, alg, counters, is_fixed:)
        alg_string = alg.to_s
        if existing_alg.alg == alg_string && existing_alg.is_fixed == is_fixed
          counters[:confirmed_algs] += 1

          return existing_alg
        end

        counters[:updated_algs] += 1
        existing_alg.alg = alg_string
        existing_alg.is_fixed = is_fixed
        return if existing_alg.save

        Rails.logger.error "Error updating alg #{alg} for case #{existing_alg.casee}:\n" \
                           "#{existing_alg.errors.full_messages.join('\n')}"
      end

      def total_cells(tables)
        tables.sum { |t| table_cells(t) }
      end

      def table_cells(table)
        return 0 if table.values.empty?

        table.values.length * table.values.map(&:length).max
      end
    end
  end
end
