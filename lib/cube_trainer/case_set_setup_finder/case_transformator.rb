# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module CaseSetSetupFinder
    # Helps transforming cases.
    class CaseTransformator
      include TwistyPuzzles
      def mirror(casee, normal_face)
        raise unless normal_face.is_a?(Face)

        mirrored_part_cycles = casee.part_cycle.map { |c| mirror_part_cycle(c, normal_face) }
        Case.new(part_cycles: mirrored_part_cycles)
      end

      def inverse(casee)
        casee.inverse
      end

      def rotate_by(casee, rotation)
        raise TypeError unless rotation.is_a?(Rotation)
        return casee if rotation.direction.zero?

        rotated_part_cycles = casee.part_cycle.map { |c| rotate_part_cycle_by(c, rotation) }
        Case.new(part_cycles: rotated_part_cycles)
      end

      private

      def mirror_part_cycle(part_cycle, normal_face)
        inverse_twist = part_cycle.inverse.twist
        mirrored_parts = part_cycle.parts.map { |_p| mirror_part(part, normal_face) }

        PartCycle.new(mirrored_parts, inverse_twist)
      end

      def rotate_part_cycle_by(part_cycle, rotation)
        rotated_parts = part_cycle.parts.map { |_p| rotate_part_by(part, rotation) }

        PartCycle.new(rotated_parts, part_cycle.twist)
      end
    end
  end
end
