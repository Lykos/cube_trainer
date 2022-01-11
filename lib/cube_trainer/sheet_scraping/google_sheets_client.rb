# frozen_string_literal: true

module CubeTrainer
  module SheetScraping
    # Client to access Google sheets API.
    class GoogleSheetsClient
      # Data of one one sheet (i.e. one tab of a spreadsheet).
      # Includes meta information and the actual values.
      class SheetTable
        def initialize(sheet_info:, values:)
          @sheet_info = sheet_info
          @values = values
        end

        attr_reader :sheet_info, :values
      end

      # Meta information about one sheet (i.e. one tab of a spreadsheet).
      class SheetInfo
        ALPHABET = ('A'..'Z').to_a.freeze

        def initialize(title:, row_count:, column_count:)
          @title = title
          @row_count = row_count
          @column_count = column_count
        end

        attr_reader :title, :row_count, :column_count

        def max_row_name
          [@row_count, 1000].min.to_s
        end

        def max_column_name
          if @column_count <= ALPHABET.length
            ALPHABET[@column_count - 1]
          elsif @column_count <= ALPHABET.length**2
            "#{ALPHABET[(@column_count - 1) / 26]}#{ALPHABET[(@column_count - 1) % 26]}"
          else
            'ZZ'
          end
        end

        def range
          "#{@title}!A1:#{max_column_name}#{max_row_name}"
        end
      end

      SCOPE = 'https://www.googleapis.com/auth/spreadsheets.readonly'

      def initialize(credentials_factory:, sheets_service_factory:, sheet_filter:)
        @credentials_factory = credentials_factory
        @sheets_service_factory = sheets_service_factory
        @sheet_filter = sheet_filter
      end

      def authorizer
        @authorizer ||= @credentials_factory.make_creds(
          json_key_io: StringIO.new(Rails.application.credentials[:google_service_account].to_json),
          scope: SCOPE
        )
      end

      def service
        @service ||=
          begin
            service = @sheets_service_factory.new
            service.authorization = authorizer
            service
          end
      end

      # Delegate doesn't work during tests here.
      def fetch_access_token!
        authorizer.fetch_access_token!
      end

      def get_sheets(spreadsheet_id)
        service.get_spreadsheet(spreadsheet_id).sheets.map do |s|
          props = s.properties
          grid_props = props.grid_properties
          SheetInfo.new(
            title: props.title,
            row_count: grid_props.row_count,
            column_count: grid_props.column_count
          )
        end
      end

      def get_tables(spreadsheet_id)
        get_sheets(spreadsheet_id).filter_map do |sheet_info|
          next unless @sheet_filter.sheet_title_passes?(sheet_info.title)

          SheetTable.new(
            sheet_info: sheet_info,
            values: service.get_spreadsheet_values(spreadsheet_id, sheet_info.range).values
          )
        end
      end
    end
  end
end
