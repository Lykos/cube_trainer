# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/training/disjoint_union_hinter'
require 'cube_trainer/training/hint_parser'
require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/training/restricted_hinter'
require 'cube_trainer/training/sequence_hinter'
require 'cube_trainer/training/transformed_hinter'
require 'twisty_puzzles'

module CubeTrainer
  module Training
    # Parses hints for an alg set (e.g. for PLLs).
    class AlgHintParser < HintParser
      include TwistyPuzzles::Utils::StringHelper
      include TwistyPuzzles

      ALG_SET_SEPARATOR = '_plus_'
      ALL_SLOTS_SUFFIX = '_all_slots'
      ADJACENT_PLL_NAME = SimpleAlgName.new('Ja')
      DIAGONAL_PLL_NAME = SimpleAlgName.new('Y')
      SOLVED_HINTER = AlgHinter.new(SimpleAlgName.new('solved') => TwistyPuzzles::Algorithm::EMPTY)
      AUF_HINTER =
        AlgHinter.new(
          ([[SimpleAlgName.new('auf skip'), TwistyPuzzles::Algorithm::EMPTY]] +
           TwistyPuzzles::CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
             alg =
               TwistyPuzzles::Algorithm.move(TwistyPuzzles::FatMove.new(TwistyPuzzles::Face::U, d))
             [SimpleAlgName.new(alg.to_s), alg]
           end).to_h
        )
      ALL_SLOT_TRANSFORMATIONS = (TwistyPuzzles::AlgorithmTransformation.around_face(TwistyPuzzles::Face::U).map do |t|
                                    [
                                      SimpleAlgName.new("#{t.rotation}#{t.mirror ? ' mirror' : ''}"), t
                                    ]
                                  end).to_h.freeze

      def initialize(name, verbose)
        super()
        @name = name
        @verbose = verbose
      end

      attr_reader :name, :verbose

      def parse_hints_internal(raw_hints)
        raw_hints.map do |row|
          if row.length != 2
            puts "Invalid alg row #{row} that doesn't have 2 entries."
            next
          end
          raw_alg_name, raw_alg = row
          alg =
            begin
              parse_algorithm(raw_alg)
            rescue TwistyPuzzles::CommutatorParseError => e
              warn "Couldn't parse alg '#{alg}': #{e}"
              next
            end
          [SimpleAlgName.new(raw_alg_name), alg]
        end.compact.to_h
      end

      def hinter_class
        AlgHinter
      end

      def self.construct_cp_hinter(verbose)
        pll_hinter = parse_hints('plls', verbose)
        diagonal_pll_hinter = RestrictedHinter.new([DIAGONAL_PLL_NAME], pll_hinter)
        one_adjacent_pll_hinter = RestrictedHinter.new([ADJACENT_PLL_NAME], pll_hinter)
        adjacent_pll_hinter = AlgSequenceHinter.new([AUF_HINTER, one_adjacent_pll_hinter])
        DisjointUnionHinter.new(
          [
            diagonal_pll_hinter,
            RestrictedHinter.trivially_restricted(adjacent_pll_hinter),
            RestrictedHinter.trivially_restricted(SOLVED_HINTER)
          ]
        )
      end

      # TODO: Move this to alg sets once those are refactored to not include inputs and stuff
      # Also make it less ugly and special casy
      def self.maybe_parse_special_hints(name, verbose)
        if name.include?(ALG_SET_SEPARATOR)
          sub_hinters = name.split(ALG_SET_SEPARATOR).map { |n| parse_hints(n, verbose) }
          AlgSequenceHinter.new(sub_hinters)
        elsif name == 'cp'
          construct_cp_hinter(verbose)
        elsif name.end_with?(ALL_SLOTS_SUFFIX)
          base_name = name[0..-ALL_SLOTS_SUFFIX - 1]
          base_hinter = parse_hinter(base_name)
          TransformedHinter.new(ALL_SLOTS_TRANSFORMATIONS, base_hinter)
        end
      end

      def self.parse_hints(name, verbose)
        maybe_parse_special_hints(name, verbose) || AlgHintParser.new(name, verbose).parse_hints
      end
    end
  end
end
