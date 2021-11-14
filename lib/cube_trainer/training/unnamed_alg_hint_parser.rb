# frozen_string_literal: true

require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/training/alg_set_reverse_engineer'
require 'cube_trainer/training/case_solution'
require 'cube_trainer/training/hint_parser'
require 'twisty_puzzles'

module CubeTrainer
  module Training
    # Parses hints for an alg set where we don't have alg names in the alg sheet,
    # but we do know for each alg what it's supposed to do and hence we can reverse
    # engineer which alg is which (e.g. for corner twists).
    class UnnamedAlgHintParser < HintParser
      include TwistyPuzzles

      def initialize(name, input_items, mode)
        super()
        @name = name
        @input_items = input_items
        @mode = mode
        @verbose = mode.verbose
      end

      attr_reader :name, :verbose

      def engineer
        @engineer ||= AlgSetReverseEngineer.new(@input_items, @mode)
      end

      def parse_hints_internal(raw_hints)
        keyed_algs = {}
        extract_commutators(raw_hints).each do |comm|
          key = engineer.find_stuff(comm.algorithm)
          keyed_algs[key] = CaseSolution.new(comm) if key
        end
        keyed_algs
      end

      def extract_commutators(raw_hints)
        comms = []
        raw_hints.each do |row|
          row.each do |cell|
            next if cell.blank?

            comm = parse_commutator(cell, complete_parse: false)
            # Ignore very short algorithms. They are never valid and they can be things like piece
            # types.
            comms.push(comm) unless comm.algorithm.length <= 3
          end
        end
        comms
      end

      def hinter_class
        AlgHinter
      end

      def self.maybe_parse_hints(name, input_items, verbose)
        new(name, input_items, verbose).maybe_parse_hints
      end
    end
  end
end
