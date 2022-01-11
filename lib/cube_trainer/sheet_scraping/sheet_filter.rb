# frozen_string_literal: true

module CubeTrainer
  module SheetScraping
    # Filter for sheet scraping. Allows to only scrape some spreadsheets or only some sheets.
    class RegexpSheetFilter
      def initialize(owner_regexp:, sheet_title_regexp:)
        @owner_regexp = owner_regexp
        @sheet_title_regexp = sheet_title_regexp
      end

      def spreadsheet_owner_passes?(owner)
        @owner_regexp.match?(owner)
      end

      def sheet_title_passes?(title)
        @sheet_title_regexp.match?(title)
      end
    end

    # sheet filter that lets everything pass.
    class AllSheetFilter
      def spreadsheet_owner_passes?(_owner)
        true
      end

      def sheet_title_passes?(_title)
        true
      end
    end
  end
end
