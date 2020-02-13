# frozen_string_literal: true

require 'csv'
require 'zip'
require 'cube_trainer/wca/file_parser'
require 'cube_trainer/wca/result'
require 'cube_trainer/core/parser'

module CubeTrainer
  module WCA
  # Parser for WCA exports
  class ExportParser
    RANKS_AVERAGE_FILE = 'WCA_export_RanksAverage.tsv'
    RANKS_SINGLE_FILE = 'WCA_export_RanksSingle.tsv'
    PERSONS_FILE = 'WCA_export_Persons.tsv'
    CONTINENTS_FILE = 'WCA_export_Continents.tsv'
    COUNTRIES_FILE = 'WCA_export_Countries.tsv'
    EVENTS_FILE = 'WCA_export_Events.tsv'
    ROUND_TYPES_FILE = 'WCA_export_RoundTypes.tsv'
    COMPETITIONS_FILE = 'WCA_export_Competitions.tsv'
    FORMATS_FILE = 'WCA_export_Formats.tsv'
    RESULTS_FILE = 'WCA_export_Results.tsv'
    SCRAMBLES_FILE = 'WCA_export_Scrambles.tsv'

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

    SCRAMBLE_SUPPORTED_EVENT_IDS = [
      '222',
      '333',
      '444',
      '555',
      '666',
      '777',
      '333bf',
      '333fm',
      '333ft',
      '333oh',
      '333mbf',
      '333mbo',
      '444bf',
      '555bf'
    ]

    def self.filter_scrambles(row)
      SCRAMBLE_SUPPORTED_EVENT_IDS.include?(row[:eventid])
    end

    RANK_ROW_PARSER = CSVRowParser.new(
      personid: Column::STRING,
      eventid: Column::STRING,
      best: Column::RESULT,
      worldrank: Column::INTEGER,
      continentrank: Column::INTEGER,
      countryrank: Column::INTEGER)

    FILE_PARSERS = {
      competitions: CSVFileParser.new(COMPETITIONS_FILE,
                                      # TODO: Parse more of these
                                      CSVRowParser.new(
                                        id: Column::STRING,
                                        name: Column::STRING,
                                        cityname: Column::STRING,
                                        countryid: Column::STRING,
                                        information: Column::STRING,
                                        year: Column::INTEGER,
                                        month: Column::INTEGER,
                                        day: Column::INTEGER,
                                        endmonth: Column::INTEGER,
                                        endday: Column::INTEGER,
                                        eventspecs: Column::STRING,
                                        wcadelegate: Column::STRING,
                                        organiser: Column::STRING,
                                        venue: Column::STRING,
                                        venueaddress: Column::STRING,
                                        venuedetails: Column::STRING,
                                        externalwebsite: Column::STRING,
                                        cellname: Column::STRING,
                                        latitude: Column::INTEGER,
                                        longitude: Column::INTEGER,
                                        startdate: Column::START_DATE,
                                        enddate: Column::END_DATE)),
      countries: CSVFileParser.new(COUNTRIES_FILE,
                                   CSVRowParser.new(
                                     id: Column::STRING,
                                     name: Column::STRING,
                                     continentid: Column::STRING,
                                     iso2: Column::STRING)),
      continents: CSVFileParser.new(CONTINENTS_FILE,
                                    CSVRowParser.new(
                                      id: Column::STRING,
                                      name: Column::STRING,
                                      recordname: Column::STRING,
                                      latitude: Column::INTEGER,
                                      longitude: Column::INTEGER,
                                      zoom: Column::INTEGER)),
      events: CSVFileParser.new(EVENTS_FILE,
                                CSVRowParser.new(
                                  id: Column::STRING,
                                  name: Column::STRING,
                                  rank: Column::INTEGER,
                                  format: Column::SYMBOL,
                                  cellname: Column::STRING)),
      formats: CSVFileParser.new(FORMATS_FILE,
                                 CSVRowParser.new(
                                   id: Column::SYMBOL,
                                   name: Column::STRING,
                                   sort_by: Column::SYMBOL,
                                   sort_by_second: Column::SYMBOL,
                                   expected_solve_count: Column::INTEGER,
                                   trim_fastest_n: Column::INTEGER,
                                   trim_slowest_n: Column::INTEGER)),
      persons: CSVFileParser.new(PERSONS_FILE,
                                 CSVRowParser.new(
                                   id: Column::STRING,
                                   subid: Column::INTEGER,
                                   name: Column::STRING,
                                   countryid: Column::SYMBOL,
                                   gender: Column::SYMBOL)),
      ranks_average: CSVFileParser.new(RANKS_AVERAGE_FILE, RANK_ROW_PARSER),
      ranks_single: CSVFileParser.new(RANKS_SINGLE_FILE, RANK_ROW_PARSER),
      results: CSVFileParser.new(RESULTS_FILE,
                                 CSVRowParser.new(
                                   competitionid: Column::STRING,
                                   eventid: Column::STRING,
                                   roundtypeid: Column::SYMBOL,
                                   pos: Column::INTEGER,
                                   best: Column::RESULT,
                                   average: Column::RESULT,
                                   personname: Column::STRING,
                                   personid: Column::STRING,
                                   personcountryid: Column::STRING,
                                   formatid: Column::SYMBOL,
                                   value1: Column::RESULT,
                                   value2: Column::RESULT,
                                   value3: Column::RESULT,
                                   value4: Column::RESULT,
                                   value5: Column::RESULT,
                                   values: Column::RESULTS,
                                   regionalsinglerecord: Column::OPTIONAL_STRING,
                                   regionalaveragerecord: Column::OPTIONAL_STRING)),
      round_types: CSVFileParser.new(ROUND_TYPES_FILE,
                                     CSVRowParser.new(
                                       id: Column::SYMBOL,
                                       rank: Column::INTEGER,
                                       name: Column::STRING,
                                       cellname: Column::SYMBOL,
                                       final: Column::BOOLEAN)),
      scrambles: CSVFileParser.new(SCRAMBLES_FILE,
                                   FilteredRowParser.new(
                                     CSVRowParser.new(
                                       scrambleid: Column::INTEGER,
                                       competitionid: Column::STRING,
                                       eventid: Column::STRING,
                                       roundtypeid: Column::SYMBOL,
                                       groupid: Column::STRING,
                                       isextra: Column::BOOLEAN,
                                       scramblenum: Column::INTEGER,
                                       scramble: Column::ALGORITHM), &method(:filter_scrambles)))
    }

    def initialize(competitions:,
                   countries:,
                   continents:,
                   events:,
                   formats:,
                   persons:,
                   ranks_average:,
                   ranks_single:,
                   results:,
                   round_types:,
                   scrambles:)
      @competitions = competitions
      @countries = countries
      @continents = continents
      @events = events
      @formats = formats
      @persons = persons
      @ranks_average = ranks_average
      @ranks_single = ranks_single
      @results = results
      @round_types = round_types
      @scrambles = scrambles
    end

    private_class_method :new

    def self.parse(filename)
      data = {}
      Zip::File.open(filename) do |zipfile|
        FILE_PARSERS.each do |key, parser|
          data[key] = parser.parse_from(zipfile)
        end
      end
      new(**data)
    end

    attr_reader :results, :continents, :countries, :competitions, :events, :people, :round_types, :scrambles

    def nemesis?(badguy, victim)
      badranks = @ranks[badguy]
      victimranks = @ranks[victim]
      victimranks.all? do |k, v|
        badranks&.key?(k) && badranks[k] < v
      end
    end

    def nemeses(wcaid)
      badguys = []
      @people.each_value do |person|
        id = person[:personid]
        next if id == wcaid

        badguys.push(id) if nemesis?(id, wcaid)
      end
      badguys
    end
  end
  end
end
