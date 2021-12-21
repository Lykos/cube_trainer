require 'googleauth'
require 'google/apis/sheets_v4'

module CubeTrainer
  module SheetScraping
    # Client to access Google sheets API.
    class GoogleSheetsClient
      class SheetTable
        def initialize(sheet_info:, values:)
          @sheet_info = sheet_info
          @values = values
        end

        attr_reader :sheet_info, :values
      end

      class SheetInfo
        ALPHABET = ('A'..'Z').to_a.freeze

        def initialize(title:, row_count:, column_count:)
          @title = title
          @row_count = row_count
          @column_count = column_count
        end

        attr_reader :title, :row_count, :column_count

        def max_column_name
          [@column_count, 1000].min.to_s
        end

        def max_row_name
          if @row_count <= ALPHABET.length
            ALPHABET[@row_count - 1]
          elsif @row_count <= ALPHABET.length ** 2
            "#{ALPHABET[(@row_count - 1) / 26]}#{ALPHABET[(@row_count - 1) % 26]}"
          else
            "ZZ"
          end
        end

        def range
          "#{@title}!A1:#{max_row_name}#{max_column_name}"
        end
      end

      SCOPE = 'https://www.googleapis.com/auth/spreadsheets.readonly'

      def authorizer
        @authorizer ||= Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(Rails.application.credentials[:google_service_account].to_json),
          scope: SCOPE
        )
      end

      def service
        @service ||= begin
                       service = Google::Apis::SheetsV4::SheetsService.new
                       service.authorization = authorizer
                       service
                     end
      end

      delegate :fetch_access_token!, to: :authorizer

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
        get_sheets(spreadsheet_id).map do |sheet_info|
          SheetTable.new(
            sheet_info: sheet_info,
            values: service.get_spreadsheet_values(spreadsheet_id, sheet_info.range).values
          )
        end
      end
    end
  end
end
