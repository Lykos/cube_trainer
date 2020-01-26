require 'cube_trainer/hint_parser'
require 'cube_trainer/alg_name'
require 'cube_trainer/sequence_hinter'
require 'cube_trainer/restricted_hinter'
require 'cube_trainer/disjoint_union_hinter'
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
        [SimpleAlgName.new(raw_alg_name), alg]
      end.compact.to_h
    end

    def hinter_class
      AlgHinter
    end

    SOLVED_HINTER = AlgHinter.new({SimpleAlgName.new('solved') => Algorithm.empty})
    CP_PLL_NAMES = [SimpleAlgName.new('Ja'), SimpleAlgName.new('Y')]
    ALG_SET_SEPARATOR = '_plus_'

    # TODO Move this to alg sets once those are refactored to not include inputs and stuff
    # Also make it less ugly and special casy
    def self.maybe_parse_special_hints(name, verbose)
      if name.include?(ALG_SET_SEPARATOR)
        sub_hinters = name.split(ALG_SET_SEPARATOR).map { |n| maybe_parse_hints(n, verbose) }
        AlgSequenceHinter.new(sub_hinters)
      elsif name == 'cp'
        pll_hinter = maybe_parse_hints('plls', verbose)
        cp_pll_hinter = RestrictedHinter.new(CP_PLL_NAMES, pll_hinter)
        DisjointUnionHinter.new([cp_pll_hinter, RestrictedHinter.trivially_restricted(SOLVED_HINTER)])
      else
        nil
      end
    end

    def self.maybe_parse_hints(name, verbose)
      maybe_parse_special_hints(name, verbose) || AlgHintParser.new(name, verbose).maybe_parse_hints
    end

  end
  
end
