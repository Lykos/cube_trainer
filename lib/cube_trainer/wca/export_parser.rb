# frozen_string_literal: true

require 'csv'
require 'zip'
require 'cube_trainer/wca/result'
require 'cube_trainer/wca/file_parsers'
require 'cube_trainer/core/parser'

module CubeTrainer
  module WCA
    # Parser for WCA exports
    class ExportParser
      include FileParsers

      # rubocop:disable Metrics/ParameterLists
      def initialize(filename:,
                     competitions:,
                     continents:,
                     countries:,
                     events:,
                     formats:,
                     persons:,
                     round_types:)
        @filename = filename
        @competitions = key_by(competitions, :competitionid)
        @countries = key_by(countries, :id)
        @continents = key_by(continents, :id)
        @events = key_by(events, :id)
        @formats = key_by(formats, :id)
        @persons = key_by(persons, :id)
        @round_types = key_by(round_types, :id)
      end
      # rubocop:enable Metrics/ParameterLists

      private_class_method :new

      def self.parse(filename)
        new(filename: filename, **parse_internal(filename, FILE_PARSERS))
      end

      def self.parse_internal(filename, parsers)
        data = {}
        Zip::File.open(filename) do |zipfile|
          parsers.each do |key, parser|
            data[key] = parser.parse_from(zipfile)
          end
        end
        data
      end

      attr_reader :competitions, :continents, :countries, :events, :formats, :persons, :round_types

      def ranks
        @ranks ||= begin
                     ranks_single_and_average = parse_ranks_single_and_average
                     ranks = {}
                     add_rank_rows(ranks_single_and_average[:ranks_average], ranks, 'average')
                     add_rank_rows(ranks_single_and_average[:ranks_single], ranks, 'single')
                     ranks
                   end.freeze
      end

      def scrambles
        @scrambles ||=
          self.class.parse_internal(@filename, scrambles: SCRAMBLES_FILE_PARSER)[:scrambles].freeze
      end

      def results
        @results ||=
          self.class.parse_internal(@filename, results: RESULTS_FILE_PARSER)[:results].freeze
      end

      def nemesis?(badguy, victim)
        badranks = ranks[badguy]
        victimranks = ranks[victim]
        victimranks.all? do |k, v|
          badranks&.key?(k) && badranks[k][:worldrank] < v[:worldrank]
        end
      end

      def nemeses(wcaid)
        badguys = []
        @persons.each_key do |id|
          next if id == wcaid

          badguys.push(id) if nemesis?(id, wcaid)
        end
        badguys
      end

      private

      def parse_ranks_single_and_average
        self.class.parse_internal(
          @filename,
          ranks_single: RANKS_SINGLE_FILE_PARSER,
          ranks_average: RANKS_AVERAGE_FILE_PARSER
        )
      end

      def add_rank_rows(rank_rows, ranks, eventid_suffix)
        rank_rows.each do |e|
          personid = e[:personid]
          person_ranks = (ranks[personid] ||= {})
          eventid = "#{e[:eventid]}_#{eventid_suffix}".to_sym
          person_ranks[eventid] = e
        end
      end

      def result(eventid, result_string)
        result_int = result_string.to_i
        format = @events[eventid][:format]
        case format
        when 'time' then Result.time(result_int)
        when 'multi' then Result.multi(result_int)
        when 'number' then Result.number(result_int)
        else raise "Unknown format #{format}."
        end
      end

      def key_by(hash, key)
        hash.map { |e| [e[key], e] }.to_h.freeze
      end
    end
  end
end
