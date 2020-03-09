# frozen_string_literal: true

require 'cube_trainer/core/parser'
require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/training/alg_set_reverse_engineer'
require 'cube_trainer/training/hint_parser'

module CubeTrainer
  module Training
    # Parses hints for an alg set where we don't have alg names in the alg sheet,
    # but we do know for each alg what it's supposed to do and hence we can reverse
    # engineer which alg is which (e.g. for corner twists).
    class UnnamedAlgSetHintParser < HintParser
      def initialize(name, input_items, verbose)
        @name = name
        @input_items = input_items
        @verbose = verbose
      end

      attr_reader :name, :verbose

      def engineer
        @engineer ||= AlgSetReverseEngineer.new(@input_items)
      end

      def parse_hints_internal(raw_hints)
        keyed_algs = {}
        extract_algs(raw_hints).each do |alg|
          key = engineer.find_stuff(alg)
          keyed_algs[key] = alg if key
        end
        keyed_algs
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
