require 'csv'
require 'zip'

module CubeTrainer

  class WCAExportReader
  
    RANKS_AVERAGE_FILE = 'WCA_export_RanksAverage.tsv'
    RANKS_SINGLE_FILE = 'WCA_export_RanksSingle.tsv'
    PERSONS_FILE = 'WCA_export_Persons.tsv'
    
    def read_ranks_file(entry, prefix)
      CSV.parse(entry.get_input_stream, col_sep: "\t") do |row|
        personid = row[0]
        eventid = row[1]
        worldrank = row[2].to_i
        next if eventid == 'eventId'
        @ranks[personid] ||= {}
        @ranks[personid][prefix + eventid] = worldrank
      end
    end
  
    def read_persons_file(entry)
      CSV.parse(entry.get_input_stream, col_sep: "\t") do |row|
        personid = row[0]
        next if personid == 'id'
        @people.push({personid: personid, name: row[2], country: row[3]})
      end    
    end
    
    def initialize(filename)
      @people = []
      @ranks = {}
      Zip::File.open(filename) do |z|
        z.each do |f|
          if f.name == RANKS_AVERAGE_FILE
            read_ranks_file(f, 'Average')
          elsif f.name == RANKS_SINGLE_FILE
            read_ranks_file(f, 'Single')
          elsif f.name == PERSONS_FILE
            read_persons_file(f)
          end
        end
      end
    end
  
    def is_nemesis?(badguy, victim)
      badranks = @ranks[badguy]
      victimranks = @ranks[victim]
      victimranks.all? do |k, v|
        badranks && badranks.has_key?(k) && badranks[k] < v
      end
    end
    
    def nemeses(wcaid)
      badguys = []
      @people.each do |person|
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
