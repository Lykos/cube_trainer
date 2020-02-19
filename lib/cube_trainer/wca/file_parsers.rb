# frozen_string_literal: true

require 'cube_trainer/wca/file_parser'

module CubeTrainer
  module WCA
    # Contains all the parsers for the relevant files of a WCA export.
    module FileParsers
      # Parsers that we apply greedily.
      FILE_PARSERS = {
        competitions: CSVFileParser.new('WCA_export_Competitions.tsv',
                                        # TODO: Parse more of these
                                        CSVRowParser.new(
                                          id: Column::STRING,
                                          name: Column::STRING,
                                          cityname: Column::STRING,
                                          countryid: Column::STRING,
                                          information: Column::OPTIONAL_STRING,
                                          year: Column::INTEGER,
                                          month: Column::INTEGER,
                                          day: Column::INTEGER,
                                          endmonth: Column::INTEGER,
                                          endday: Column::INTEGER,
                                          eventspecs: Column::STRING,
                                          wcadelegate: Column::STRING,
                                          organiser: Column::OPTIONAL_STRING,
                                          venue: Column::OPTIONAL_STRING,
                                          venueaddress: Column::OPTIONAL_STRING,
                                          venuedetails: Column::OPTIONAL_STRING,
                                          external_website: Column::OPTIONAL_STRING,
                                          cellname: Column::STRING,
                                          latitude: Column::INTEGER,
                                          longitude: Column::INTEGER,
                                          startdate: Column::START_DATE,
                                          enddate: Column::END_DATE
                                        )),
        countries: CSVFileParser.new('WCA_export_Countries.tsv',
                                     CSVRowParser.new(
                                       id: Column::STRING,
                                       name: Column::STRING,
                                       continentid: Column::STRING,
                                       iso2: Column::STRING
                                     )),
        continents: CSVFileParser.new('WCA_export_Continents.tsv',
                                      CSVRowParser.new(
                                        id: Column::STRING,
                                        name: Column::STRING,
                                        recordname: Column::OPTIONAL_STRING,
                                        latitude: Column::INTEGER,
                                        longitude: Column::INTEGER,
                                        zoom: Column::INTEGER
                                      )),
        events: CSVFileParser.new('WCA_export_Events.tsv',
                                  CSVRowParser.new(
                                    id: Column::STRING,
                                    name: Column::STRING,
                                    rank: Column::INTEGER,
                                    format: Column::SYMBOL,
                                    cellname: Column::STRING
                                  )),
        formats: CSVFileParser.new('WCA_export_Formats.tsv',
                                   CSVRowParser.new(
                                     id: Column::SYMBOL,
                                     name: Column::STRING,
                                     sort_by: Column::SYMBOL,
                                     sort_by_second: Column::SYMBOL,
                                     expected_solve_count: Column::INTEGER,
                                     trim_fastest_n: Column::INTEGER,
                                     trim_slowest_n: Column::INTEGER
                                   )),
        persons: CSVFileParser.new('WCA_export_Persons.tsv',
                                   CSVRowParser.new(
                                     id: Column::STRING,
                                     subid: Column::INTEGER,
                                     name: Column::STRING,
                                     countryid: Column::SYMBOL,
                                     gender: Column::OPTIONAL_STRING
                                   )),
        round_types: CSVFileParser.new('WCA_export_RoundTypes.tsv',
                                       CSVRowParser.new(
                                         id: Column::SYMBOL,
                                         rank: Column::INTEGER,
                                         name: Column::STRING,
                                         cellname: Column::SYMBOL,
                                         final: Column::BOOLEAN
                                       ))
      }.freeze

      def rank_row_parser(events)
        CSVRowParser.new(
          personid: Column::STRING,
          eventid: Column::STRING,
          best: Column.result(events),
          worldrank: Column::INTEGER,
          continentrank: Column::INTEGER,
          countryrank: Column::INTEGER
        )
      end

      def ranks_average_file_parser(events)
        CSVFileParser.new('WCA_export_RanksAverage.tsv', rank_row_parser(events))
      end

      def ranks_single_file_parser(events)
        CSVFileParser.new('WCA_export_RanksSingle.tsv', rank_row_parser(events))
      end

      def results_file_parser(events)
        CSVFileParser.new('WCA_export_Results.tsv',
                          CSVRowParser.new(
                            competitionid: Column::STRING,
                            eventid: Column::STRING,
                            roundtypeid: Column::SYMBOL,
                            pos: Column::INTEGER,
                            best: Column.result(events),
                            average: Column.result(events),
                            personname: Column::STRING,
                            personid: Column::STRING,
                            personcountryid: Column::STRING,
                            formatid: Column::SYMBOL,
                            value1: Column.result(events),
                            value2: Column.result(events),
                            value3: Column.result(events),
                            value4: Column.result(events),
                            value5: Column.result(events),
                            values: Column.results(events),
                            regionalsinglerecord: Column::OPTIONAL_STRING,
                            regionalaveragerecord: Column::OPTIONAL_STRING
                          ))
      end

      SCRAMBLES_FILE_PARSER = CSVFileParser.new('WCA_export_Scrambles.tsv',
                                                CSVRowParser.new(
                                                  scrambleid: Column::INTEGER,
                                                  competitionid: Column::STRING,
                                                  eventid: Column::STRING,
                                                  roundtypeid: Column::SYMBOL,
                                                  groupid: Column::STRING,
                                                  isextra: Column::BOOLEAN,
                                                  scramblenum: Column::INTEGER,
                                                  scramble: Column::ALGORITHM
                                                ))
    end
  end
end
