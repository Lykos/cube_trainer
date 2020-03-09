# frozen_string_literal: true

require 'cube_trainer/utils/string_helper'
require 'csv'

module CubeTrainer
  module Training
    # Class that parses hints from an algorithm or commutator file.
    class HintParser
      include Utils::StringHelper

      def csv_file
        "data/#{hint_type}/#{name}.csv"
      end

      def hint_type
        class_name = snake_case_class_name(self.class)
        raise unless class_name.end_with?('_hint_parser')

        class_name.gsub(/_hint_parser$/, 's')
      end

      def name
        raise NotImplementedError
      end

      def verbose
        raise NotImplementedError
      end

      def read_hints
        CSV.read(csv_file)
      end

      def hints_exist?
        File.exist?(csv_file)
      end

      def maybe_parse_hints
        hints =
          if hints_exist?
            parse_hints_internal(read_hints)
          else
            puts "Failed to find hint CSV file #{hint_parser.csv_file}." if verbose
            {}
          end
        hinter_class.new(hints)
      end

      def parse_hints
        raise ArgumentError, "No algorithm sheet found at #{csv_file}." unless hints_exist?

        maybe_parse_hints
      end

      def hinter_class
        raise NotImplementedError
      end

      def parse_hints_internal(*)
        raise NotImplementedError
      end
    end
  end
end
