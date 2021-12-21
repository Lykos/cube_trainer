require_relative 'google_sheets_client'
require_relative 'alg_extractor'

module CubeTrainer
  module SheetScraping
    # Client that scrapes alg sets from Google sheets.
    class GoogleSheetsScraper
      def run
        AlgSpreadsheet.all.each do |alg_spreadsheet|
          scrape_sheet(alg_spreadsheet)
        end
      end

      def scrape_sheet(alg_spreadsheet)
        Rails.logger.info "Scraping #{alg_spreadsheet.spreadsheet_id} by #{alg_spreadsheet.owner}."
        tables = sheets_client.get_tables(alg_spreadsheet.spreadsheet_id)
        Rails.logger.info "Got #{tables.length} sheets with a total of #{total_cells(tables)} cells."
        counters = {updated_algs: 0, new_algs: 0, confirmed_algs: 0}
        tables.map { |t| extract_alg_set(alg_spreadsheet, t, counters) }
        Rails.logger.info "Got #{counters[:new_algs]} new algs, updated #{counters[:updated_algs]} algs and confirmed #{counters[:confirmed_algs]} algs."
      end

      private

      def mode_type(alg_set)
        ModeType.all.find { |m| (defined? m.generator_class::PART_TYPE) && m.generator_class::PART_TYPE == alg_set.part_type } || raise
      end

      def extract_alg_set(alg_spreadsheet, table, counters)
        extracted_alg_set = AlgExtractor.extract_alg_set(table) || return
        alg_set = alg_spreadsheet.alg_sets.find_or_create_by!(
          mode_type: mode_type(extracted_alg_set),
          sheet_title: table.sheet_info.title,
          buffer: extracted_alg_set.buffer
        )
        extracted_alg_set.algs.each do |part_cycle, alg|
          save_alg(alg_set, part_cycle, alg, counters)
        end
        extracted_alg_set.fixes.each do |fix|
          save_alg(alg_set, fix.cell_description.part_cycle, fix.fixed_algorithm, counters, is_fixed: true)
        end
      end

      def save_alg(alg_set, part_cycle, alg, counters, is_fixed: false)
        case_key = InputRepresentationType.new.serialize(part_cycle)
        existing_alg = alg_set.algs.find_by(case_key: case_key)
        unless existing_alg
          counters[:new_algs] += 1
          return alg_set.algs.create!(
            case_key: case_key,
            alg: alg
          )
        end
        alg_string = alg.to_s
        if existing_alg.alg == alg_string
          counters[:confirmed_algs] += 1
          
          return existing_alg
        end

        counters[:updated_algs] += 1
        existing_alg.alg = alg_string
        existing_alg.save!
      end

      def sheets_client
        @sheets_client ||= GoogleSheetsClient.new
      end

      def total_cells(tables)
        tables.map { |t| table_cells(t) }.sum
      end

      def table_cells(table)
        return 0 if table.values.empty?

        table.values.length * table.values.map(&:length).max
      end
    end
  end
end
