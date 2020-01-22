require 'cube_trainer/hint_parser'
require 'cube_trainer/alg_name'
require 'cube_trainer/alg_hinter'
require 'cube_trainer/parser'

module CubeTrainer

  class AlgHintParser < HintParser
    include StringHelper

    def initialize(name, verbose)
      @name = name
      @verbose = verbose
    end

    attr_reader :name, :verbose

    def parse_hints(raw_hints)
      hints = raw_hints.map do |row|
        if row.length != 2
          puts "Invalid alg row #{row} that doesn't have 2 entries."
          next
        end
        raw_alg_name, raw_alg = row
        alg = begin
                parse_algorithm(raw_alg)
              rescue CommutatorParseError => e
                puts "Couldn't parse alg: #{alg}"
                next
              end
        [AlgName.new(raw_alg_name), alg]
      end.compact.to_h
    end

    def hinter_class
      AlgHinter
    end

    def self.maybe_parse_hints(name, verbose)
      AlgHintParser.new(name, verbose).maybe_parse_hints
    end

  end
  
end
