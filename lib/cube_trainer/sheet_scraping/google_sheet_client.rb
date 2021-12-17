require 'googleauth'
require 'google/apis/sheets_v4'

module CubeTrainer
  module SheetScraping
    class GoogleSheetClient
      SheetInfo = Struct.new(:id, :row_count, :column_count)

      SCOPE = 'https://www.googleapis.com/auth/spreadsheets.readonly'
      SHEET = '1txRjB-fAWWSM-1e1w-eJbDp9xhu0ZDwLWQdswNZhcew'

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

      def get_sheets
        service.get_spreadsheet(SHEET).sheets.map do |s|
          props = s.properties
          grid_props = props.grid_properties
          SheetInfo.new(
            props.sheet_id,
            grid_props.row_count,
            grid_props.column_count
          )
        end
      end
    end
  end
end
