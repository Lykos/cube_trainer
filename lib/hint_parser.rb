require 'string_helper'
require 'csv'

module CubeTrainer

  class HintParser

    include StringHelper

    def csv_file
      "data/#{hint_type}/#{name}.csv"
    end

    def hint_type
      class_name = snake_case_class_name(self.class)
      raise unless class_name.end_with?("_hint_parser")
      class_name.gsub(/_hint_parser$/, "s")
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
      File.exists(csv_file)
    end

    def maybe_parse_hints
      hints = if hints_exist?
                parse_hints(read_hints)
              else
                puts "Failed to find hint CSV file #{hint_parser.csv_file}." if verbose
                {}
              end
      hinter_class.new(hints)
    end

    def hinter_class
      raise NotImplementedError
    end

    def parse_hints
      raise NotImplementedError
    end

  end

end
