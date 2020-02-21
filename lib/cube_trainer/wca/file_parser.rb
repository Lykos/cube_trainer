# frozen_string_literal: true

require 'cube_trainer/core/parser'
require 'cube_trainer/wca/result'

module CubeTrainer
  module WCA
    # Represents one column in a CSV file from the WCA export and contains parsing utilities.
    class Column
      extend Core

      def initialize(&block)
        @transformation = block
      end

      END_DATE =
        new do |_e, r|
          end_month = Integer(r[:endmonth], 10)
          end_day = Integer(r[:endday], 10)
          end_before_start = date_order_proxy(end_month, end_day) >
                             date_order_proxy(Integer(r[:month], 10), Integer(r[:day], 10))
          end_year = end_before_start ? Integer(r[:year], 10) + 1 : Integer(r[:year], 10)
          Time.new(end_year, Integer(r[:endmonth], 10), Integer(r[:endday], 10))
        end
      RESULT_KEYS = %i[value1 value2 value3 value4 value5].freeze
      ALGORITHM = new { |e, r| parse_algorithm_for_eventid(e, r[:eventid]) }
      START_DATE = new { |_e, r| Time.new(r[:year], r[:month], r[:day]) }
      BOOLEAN =
        new do |e, _r|
          case e
          when '0' then false
          when '1' then true
          else raise ArgumentError
          end
        end
      NXN_EVENT_IDS = %w[
        222
        333
        444
        555
        666
        777
        333bf
        333fm
        333ft
        333oh
        333mbf
        333mbo
        444bf
        555bf
      ].freeze
      SYMBOL =
        new do |e, _r|
          raise ArgumentError unless e

          e.to_sym
        end
      INTEGER =
        new do |e, _r|
          raise ArgumentError unless e

          Integer(e, 10)
        end
      STRING =
        new do |e, _r|
          raise ArgumentError unless e

          e
        end
      OPTIONAL_STRING = new { |e, _r| e unless e.nil? }

      def extract(raw_value, row)
        @transformation.call(raw_value, row)
      end

      private_class_method :new

      # TODO: Provide more powerful creation methods for columns and
      # move these overly specific ones out of this file

      # TODO: Use event id to parse skewb and stuff
      def self.parse_algorithm_for_eventid(alg_string, eventid)
        NXN_EVENT_IDS.include?(eventid) ? parse_algorithm(alg_string) : nil
      end

      # Returns a number that can be used to order the given month/day combination.
      def self.date_order_proxy(month, day)
        month * 32 + day
      end

      def self.parse_result(result_string, format)
        result_int = Integer(result_string, 10)
        case format
        when :time then Result.time(result_int)
        when :multi then Result.multi(result_int)
        when :number then Result.number(result_int)
        else raise "Unknown format #{format}."
        end
      end

      def self.result(events)
        new do |e, r|
          eventid = r[:eventid]
          format = events[eventid][:format]
          parse_result(e, format)
        end
      end

      def self.results(events)
        result = result(events)
        new do |_e, r|
          RESULT_KEYS.map { |k| result.extract(r[k], r) }
        end
      end
    end

    # Helper class to parse rows from a WCA export CSV file.
    class CSVRowParser
      def initialize(columns)
        @columns = columns
      end

      def parse_row(row)
        @columns.map do |key, column|
          value = column.extract(row[key], row)
          [key, value]
        end.to_h
      end
    end

    # Helper class to filter rows from a WCA export CSV file before parsing.
    class FilteredRowParser
      def initialize(subparser, &block)
        @subparser = subparser
        @filter = block
      end

      def parse_row(row)
        @subparser.parse_row(row) if @filter.call(row)
      end
    end

    # Helper class to map parsed rows from a WCA export CSV file.
    class MappedRowParser
      def initialize(subparser, &block)
        @subparser = subparser
        @transformation = block
      end

      def parse_row(row)
        @transformation.call(@subparser.parse_row(row))
      end
    end

    # Helper class to parse WCA export CSV files.
    class CSVFileParser
      COL_SEP = "\t"

      def initialize(filename, row_parser)
        @filename = filename
        @row_parser = row_parser
      end

      def parse_from(zipfile)
        result = []
        CSV.parse(
          zipfile.get_input_stream(@filename),
          col_sep: COL_SEP,
          liberal_parsing: true,
          headers: true,
          header_converters: :symbol
        ) do |row|
          parsed_row = @row_parser.parse_row(row)
          result.push(parsed_row) if parsed_row
        end
        result
      end
    end
  end
end
