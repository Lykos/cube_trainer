require 'csv'
require 'zip'
require 'cube_trainer/wca_result'
require 'cube_trainer/parser'

module CubeTrainer

  class WCAExportReader
  
    RANKS_AVERAGE_FILE = 'WCA_export_RanksAverage.tsv'
    RANKS_SINGLE_FILE = 'WCA_export_RanksSingle.tsv'
    PEOPLE_FILE = 'WCA_export_Persons.tsv'
    CONTINENTS_FILE = 'WCA_export_Continents.tsv'
    COUNTRIES_FILE = 'WCA_export_Countries.tsv'
    EVENTS_FILE = 'WCA_export_Events.tsv'
    ROUND_TYPES_FILE = 'WCA_export_RoundTypes.tsv'
    COMPETITIONS_FILE = 'WCA_export_Competitions.tsv'  
    FORMATS_FILE = 'WCA_export_Formats.tsv'
    RESULTS_FILE = 'WCA_export_Results.tsv'
    SCRAMBLES_FILE = 'WCA_export_Scrambles.tsv'
    COL_SEP = "\t"

    def result(eventid, result_string)
      result_int = result_string.to_i
      format = @events[eventid][:format]
      case format
      when 'time' then WCAResult.time(result_int)
      when 'multi' then WCAResult.multi(result_int)
      when 'number' then WCAResult.number(result_int)
      else
        raise "Unknown format #{format}."
      end
    end
    
    def read_ranks_file(input_stream, prefix)
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        personid = row[0]
        eventid = row[1]
        worldrank = row[2].to_i
        next if eventid == 'eventId'
        @ranks[personid] ||= {}
        @ranks[personid][prefix + eventid] = worldrank
      end
    end
  
    def read_people_file(input_stream)
      @people = {}
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        personid = row[0]
        next if personid == 'id'
        @people[personid] = {personid: personid, subid: row[1], name: row[2],
                             country: row[3], gender: row[4]}
      end    
    end

    def read_continents_file(input_stream)
      @continents = {}
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        continentid = row[0]
        next if continentid == 'id'
        @continents[continentid] = {continentid: continentid, name: row[1],
                                    recordName: row[2], latitude: row[4],
                                    longitude: row[5], zoom: row[6]}
      end
    end

    def read_countries_file(input_stream)
      @countries = {}
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        countryid = row[0]
        next if countryid == 'id'
        @countries[countryid] = {countryid: countryid, name: row[1],
                                 continentid: row[2], iso2: row[3]}
      end
    end

    def read_formats_file(input_stream)
      @formats = {}
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        formatid = row[0]
        next if formatid == 'id'
        @formats[formatid] = {formatid: formatid, name: row[1],
                              sortby: row[2], sortbysecond: row[3], expectedsolvecount: row[4],
                              trim_fastest_n: row[5].to_i, trim_slowest_n: row[6].to_i}
      end
    end

    def read_events_file(input_stream)
      @events = {}
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        eventid = row[0]
        next if eventid == 'id'
        @events[eventid] = {eventid: eventid, name: row[1],
                            rank: row[2], format: row[3], cellName: row[4]}
      end
    end

    def read_competitions_file(input_stream)
      @competitions = {}
      CSV.parse(input_stream, col_sep: COL_SEP, quote_char: "\x00") do |row|
        competitionid = row[0]
        next if competitionid == 'id'
        year = row[5].to_i
        startdate = Time.new(year, row[6].to_i, row[7].to_i)
        enddate = Time.new(year, row[8].to_i, row[9].to_i)
        eventspecs = row[10].split(' ')
        # TODO parse these
        wcadelegate = row[11]
        organizer = row[12]
        venue = row[13]
        @competitions[competitionid] = {competitionid: competitionid, name: row[1], cityname: row[2],
                                        countryid: row[3], information: row[4], startdate: startdate,
                                        enddate: enddate, eventspecs: eventspecs, wcadelegate: wcadelegate,
                                        organizer: organizer, venue: venue, venueaddress: row[14],
                                        venuedetails: row[15], externalwebsite: row[16], cellname: row[17],
                                        latitude: row[18], longitude: row[19]}
      end
    end

    def read_round_types_file(input_stream)
      @round_types = []
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        roundtypeid = row[0]
        next if roundtypeid == 'id'
        @round_types.push({roundtypeid: roundtypeid, rank: row[1].to_i, name: row[2],
                           cellname: row[3], final: row[4].to_i > 0})
      end
    end

    def read_results_file(input_stream)
      @results = []
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        competitionid = row[0]
        next if competitionid == 'competitionId'
        eventid = row[1]
        values = row[10..14].select { |e| !e.empty? }.map { |v| result(eventid, v) }
        @results.push({competitionid: competitionid, eventid: eventid,
                       roundtypeid: row[2], pos: row[3].to_i, best: result(eventid, row[4]),
                       average: result(eventid, row[5]), personname: row[6], personid: row[7],
                       personcountryid: row[8], formatid: row[9],
                       values: values, regionalsinglerecord: row[15],
                       regionalaveragerecord: row[16]})
      end
    end
    
    def read_scrambles_file(input_stream)
      @scrambles3x3 = []
      CSV.parse(input_stream, col_sep: COL_SEP) do |row|
        scrambleid = row[0]
        next if scrambleid == 'scrambleId'
        eventid = row[2]
        next unless eventid == '333'
        isextra = row[4].to_i == 1
        @scrambles3x3.push({scrambleid: scrambleid,
                            competitionid: row[1],
                            eventid: eventid,
                            roundtypeid: row[2],
                            groupid: row[3],
                            isextra: isextra,
                            scramblenum: row[5].to_i,
                            scramble: parse_algorithm(row[6])})
      end
    end
    
    def initialize(filename)
      @ranks = {}
      Zip::ZipFile.open(filename) do |z|
        read_continents_file(z.get_input_stream(CONTINENTS_FILE))
        read_countries_file(z.get_input_stream(COUNTRIES_FILE))
        read_formats_file(z.get_input_stream(FORMATS_FILE))
        read_round_types_file(z.get_input_stream(ROUND_TYPES_FILE))
        read_events_file(z.get_input_stream(EVENTS_FILE))
        read_competitions_file(z.get_input_stream(COMPETITIONS_FILE))
        read_results_file(z.get_input_stream(RESULTS_FILE))
        read_people_file(z.get_input_stream(PEOPLE_FILE))
        read_ranks_file(z.get_input_stream(RANKS_AVERAGE_FILE), 'Average')
        read_ranks_file(z.get_input_stream(RANKS_SINGLE_FILE), 'Single')
        read_scrambles_file(z.get_input_stream(SCRAMBLES_FILE))
      end
    end

    attr_reader :results, :continents, :countries, :competitions, :events, :people, :round_types

    def is_nemesis?(badguy, victim)
      badranks = @ranks[badguy]
      victimranks = @ranks[victim]
      victimranks.all? do |k, v|
        badranks && badranks.has_key?(k) && badranks[k] < v
      end
    end
    
    def nemeses(wcaid)
      badguys = []
      @people.each_value do |person|
        id = person[:personid]
        next if id == wcaid
        if is_nemesis?(id, wcaid)
          badguys.push(id)
        end
      end
      badguys
    end

  end

end
