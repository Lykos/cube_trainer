# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/training/case_solution'
require 'cube_trainer/training/disjoint_union_hinter'
require 'cube_trainer/training/hint_parser'
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

      def self.transformation_name(transformation)
        SimpleAlgName.new("#{transformation.rotation}#{transformation.mirror ? ' mirror' : ''}")
      end

      ALG_SET_SEPARATOR = '_plus_'
      ALTERNATIVE_ALG_SEPARATOR = ','
      ADJACENT_PLL_NAME = SimpleAlgName.new('Ja')
      DIAGONAL_PLL_NAME = SimpleAlgName.new('Y')
      SOLVED_HINTER = AlgHinter.new(
        SimpleAlgName.new('solved') => CaseSolution.new(TwistyPuzzles::Algorithm::EMPTY)
      )
      AUF_HINTER =
        AlgHinter.new(
          ([[SimpleAlgName.new('auf skip'), TwistyPuzzles::Algorithm::EMPTY]] +
           TwistyPuzzles::CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
             alg =
               TwistyPuzzles::Algorithm.move(TwistyPuzzles::FatMove.new(TwistyPuzzles::Face::U, d))
             [SimpleAlgName.new(alg.to_s), alg]
           end).to_h.transform_values { |alg| CaseSolution.new(alg) }
        )

      def initialize(name, cube_size, verbose)
        super()
        @name = name
        @cube_size = cube_size
        @verbose = verbose
      end

      attr_reader :name, :cube_size, :verbose

      def maybe_parse_alg(alg_type, raw_alg)
        parse_algorithm(raw_alg)
      rescue TwistyPuzzles::CommutatorParseError => e
        warn "Couldn't parse #{alg_type} alg '#{alg}': #{e}"
        nil
      end

      def parse_alternative_algs(maybe_raw_alternative_algs)
        raw_alternative_algs = (maybe_raw_alternative_algs || '').split(ALTERNATIVE_ALG_SEPARATOR)
        alternative_algs = raw_alternative_algs.map! do |raw_alg|
          maybe_parse_alg('alternative_alg', raw_alg)
        end.compact
        alternative_algs.compact!
        alternative_algs
      end

      def parse_hints_internal(raw_hints)
        raw_hints.map do |row|
          if row.length != 2 && row.length != 3
            puts "Invalid alg row #{row} that doesn't have 2 or 3 entries."
            next
          end
          raw_alg_name, raw_best_alg, maybe_raw_alternative_algs = row
          best_alg = maybe_parse_alg('best_alg', raw_best_alg)
          next unless best_alg

          alternative_algs = parse_alternative_algs(maybe_raw_alternative_algs)
          [
            SimpleAlgName.new(raw_alg_name),
            CaseSolution.new(best_alg, alternative_algs)
          ]
        end.compact.to_h
      end

      def hinter_class
        AlgHinter
      end

      def self.construct_cp_hinter(cube_size, verbose)
        pll_hinter = parse_hints('plls', cube_size, verbose)
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
      def self.maybe_parse_special_hints(name, cube_size, verbose)
        if name.include?(ALG_SET_SEPARATOR)
          sub_hinters = name.split(ALG_SET_SEPARATOR).map { |n| parse_hints(n, cube_size, verbose) }
          AlgSequenceHinter.new(sub_hinters)
        elsif name == 'cp'
          construct_cp_hinter(cube_size, verbose)
        end
      end

      def self.parse_hints(name, cube_size, verbose)
        maybe_parse_special_hints(
          name, cube_size,
          verbose
        ) || AlgHintParser.new(
          name, cube_size,
          verbose
        ).parse_hints
      end
    end
  end
end
