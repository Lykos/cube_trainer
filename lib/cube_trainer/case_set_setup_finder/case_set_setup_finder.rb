# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/case_set_setup_finder/case_set_seed_algs'

module CubeTrainer
  module CaseSetSetupFinder
    # Finds setups for each case in a case set.
    # Note that the setups might be bad algs for humans, but they might be useful for machine processing.
    class CaseSetSetupFinder
      def initialize(case_set)
        raise TypeError unless case_set.is_a?(CaseSets::ConcreteCaseSet)

        @case_set = case_set
      end

      attr_reader :case_set

      def find_setup(casee)
        raise ArgumentError unless casee.valid?
        raise ArgumentError unless @case_set.match?(casee)

        setup_hash[casee.canonicalize(ignore_same_face_center_cycles: true)]
      end

      private

      include TwistyPuzzles
      include CaseSetSeedAlgs

      def case_reverse_engineer
        @case_reverse_engineer ||=
          CubeTrainer::CaseReverseEngineer.new(
            cube_size: @case_set.default_cube_size
          )
      end

      def create_setup_hash
        setup_hash = {}
        cases = @case_set.cases
        algs = initial_algs

        5.times do
          useful_algs = []
          algs.each do |alg|
            casee = case_reverse_engineer.find_case(alg)

            found_cases = cases.select { |c| c.equivalent?(casee) }
            next if found_cases.empty?
            raise if found_cases.lenght > 1

            useful_algs.push(alg)
            setup_hash[found_cases.first] = alg.inverse
            cases -= found_cases
          end
          return setup_hash if cases.empty?

          algs = useful_algs.flat_map { |alg| setup_algs.flat_map { |s| s + alg + s.inverse } }
        end
        raise "Couldn't find algs for all cases for #{@case_set.class}." unless cases.empty?
      end

      def setup_hash
        @setup_hash ||= create_setup_hash
      end
    end
  end
end
