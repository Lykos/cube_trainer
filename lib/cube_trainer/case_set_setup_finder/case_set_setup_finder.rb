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
            cube_size: cube_size
          )
      end

      def cube_size
        @case_set.default_cube_size
      end

      def move(algorithm)
        raise ArgumentError unless algorithm.length == 1

        algorithm.moves.first
      end

      def apply_move_to_case(casee, move)
        raise TypeError unless casee.is_a?(Case)
        raise TypeError unless move.is_a?(CubeMove)
        return casee.rotate_by(move) if move.is_a?(Rotation)

        Case.new(part_cycles: casee.part_cycles.map { |c| apply_move_to_part_cycle(c, move) })
      end

      def apply_move_to_part_cycle(part_cycle, move)
        changed_parts = part_cycle.parts.map { |p| apply_move_to_part(p, move) }
        PartCycle.new(changed_parts, part_cycle.twist)
      end

      def apply_move_to_part(part, move)
        return part unless affected_by?(part, move)

        part.rotate_by_rotation(to_rotation(move))
      end

      def affected_by?(part, move)
        coordinate = part.solved_coordinate(cube_size)
        distance = coordinate.distance_to(move.axis_face)
        case move
        when FatMSliceMove
          distance.positive? && distance < cube_size
        when MaybeFatMSliceMaybeInnerMSliceMove, MaybeFatMaybeSliceMove
          affected_by?(part, move.decide_meaning(cube_size))
        when FatMove
          distance < move.width
        when SliceMove
          distance == move.slice_index
        else raise ArgumentError
        end
      end

      def to_rotation(move)
        Rotation.new(move.axis_face, move.direction)
      end

      def next_algs(cased_algs)
        cased_algs.flat_map do |cased_alg|
          casee = cased_alg[:casee]
          alg = cased_alg[:algorithm]
          setup_algs.flat_map do |s|
            {
              casee: apply_move_to_case(casee, move(s)),
              algorithm: s + alg + s.inverse
            }
          end
        end
      end

      def create_setup_hash
        setup_hash = {}
        cases = @case_set.cases
        cased_algs = initial_cased_algs

        5.times do
          useful_cased_algs = []
          cased_algs.each do |cased_alg|
            casee = cased_alg[:casee]
            alg = cased_alg[:algorithm]
            found_cases = cases.select { |c| c.equivalent?(casee) }
            next if found_cases.empty?
            raise if found_cases.length > 1

            useful_cased_algs.push(cased_alg)
            setup_hash[found_cases.first] = alg.inverse
            cases -= found_cases
          end
          return setup_hash if cases.empty?

          cased_algs = next_algs(useful_cased_algs)
        end
        raise "Couldn't find algs for all cases for #{@case_set.class}." unless cases.empty?
      end

      def setup_hash
        @setup_hash ||= create_setup_hash
      end
    end
  end
end
