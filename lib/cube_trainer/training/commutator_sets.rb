# frozen_string_literal: true

require 'cube_trainer/part_cycle_helper'
require 'cube_trainer/part_cycle_sequence'
require 'cube_trainer/training/disjoint_union_part_cycle_alg_set'
require 'cube_trainer/training/part_cycle_alg_set'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # Module containing useful methods for various sets of corner twists.
    module CornerTwistSetsHelper
      ORIENTATION_FACES = [TwistyPuzzles::Face::U, TwistyPuzzles::Face::D].freeze

      def orientation_face(part)
        faces = ORIENTATION_FACES.select { |f| part.face_symbols.include?(f.face_symbol) }
        unless faces.length == 1
          raise "Couldn't determine unique orientation face for #{part}: #{faces}"
        end

        faces.first
      end

      def rotate_orientation_face_up(part)
        part.rotate_face_up(orientation_face(part))
      end

      def non_buffer_corners
        self.class::PART_TYPE::ELEMENTS.reject { |c| c.turned_equals?(@training_session.buffer) }
      end

      def correctly_oriented_corners
        self.class::PART_TYPE::ELEMENTS.select do |c|
          ORIENTATION_FACES.include?(c.solved_face)
        end
      end

      def non_buffer_correctly_oriented_corners
        non_buffer_corners.select do |c|
          ORIENTATION_FACES.include?(c.solved_face)
        end
      end

      def non_buffer_incorrectly_oriented_corners
        non_buffer_corners.reject do |c|
          ORIENTATION_FACES.include?(c.solved_face)
        end
      end
    end

    # Class that generates input items for floating corner 2 twists.
    class FloatingCorner2Twists < PartCycleAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner

      def goal_badness
        2.0
      end

      def part_cycle_factory
        @part_cycle_factory ||= TwistyPuzzles::StickerCycleFactory.new(
          @training_session.cube_size,
          0
        )
      end

      def cube_state
        @cube_state ||= @training_session.solved_cube_state
      end

      def generate_input_items
        correctly_oriented_corners.permutation(2).map do |c1, c2|
          twisted_corner_pair = [c1.rotate_by(1), c2.rotate_by(2)]
          part_cycle = TwistyPuzzles::PartCycle.new(twisted_corner_pair.sort)
          twist_sticker_cycles = part_cycle_factory.multi_twist([c1]) +
                                 part_cycle_factory.multi_twist([c2]).inverse
          twisted_cube_state = twist_sticker_cycles.apply_to_dupped(cube_state)
          InputItem.new(part_cycle, twisted_cube_state)
        end
      end
    end

    # Class that generates input items for floating corner 2 twists and 3 twists.
    class FloatingCorner2TwistsAnd3Twists < DisjointUnionPartCycleAlgSet
      PART_TYPE = TwistyPuzzles::Corner

      def initialize(training_session)
        super(
          training_session,
          FloatingCorner2Twists.new(training_session),
          Corner3Twists.new(training_session)
        )
      end

      def buffer_coordinates
        @buffer_coordinates ||=
          TwistyPuzzles::Coordinate.solved_positions(
            @training_session.buffer,
            @training_session.cube_size, 0
          )
      end

      def generate_input_items
        super.each do |input_item|
          next unless input_item.cube_state

          # Mask the buffer s.t. it's not too obvious whether it's a 2 twist or 3 twist.
          buffer_coordinates.each do |c|
            input_item.cube_state[c] = :unknown
          end
        end
      end
    end

    # Class that generates input items for corner twists plus parities.
    class CornerTwistsPlusParities < PartCycleAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner
      PARITY_PART_TYPE = TwistyPuzzles::Edge

      def goal_badness
        3.0
      end

      def generate_part_cycles
        unfiltered_targets = non_buffer_corners.product(non_buffer_incorrectly_oriented_corners)
        parity_twist_combinations =
          unfiltered_targets.reject do |parity, twist|
            parity.turned_equals?(twist)
          end
        parity_twist_combinations.map do |targets|
          PartCycleSequence.new(targets.map { |t| TwistyPuzzles::PartCycle.new([buffer, t]) })
        end
      end
    end

    # Class that generates input items for corner 3 twists.
    class Corner3Twists < PartCycleAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner

      def goal_badness
        2.5
      end

      # rubocop:disable Metrics/AbcSize
      def generate_input_items
        cube_state = @training_session.solved_cube_state
        part_cycle_factory = TwistyPuzzles::StickerCycleFactory.new(@training_session.cube_size, 0)
        buffer_twist = part_cycle_factory.multi_twist([@training_session.buffer])
        1.upto(2).collect_concat do |twist_number|
          buffer_twist.apply_to(cube_state)
          non_buffer_correctly_oriented_corners.combination(2).collect_concat do |c1, c2|
            twisted_corner_pair = [c1.rotate_by(twist_number), c2.rotate_by(twist_number)]
            part_cycle = TwistyPuzzles::PartCycle.new([buffer] + twisted_corner_pair.sort)
            twist_sticker_cycles = part_cycle_factory.multi_twist([c1, c2])
            twist_sticker_cycles = twist_sticker_cycles.inverse if twist_number == 2
            twisted_cube_state = twist_sticker_cycles.apply_to_dupped(cube_state)
            InputItem.new(part_cycle, twisted_cube_state)
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end

    # Class that generates input items for floating edge flips.
    class FloatingEdgeFlips < PartCycleAlgSet
      PART_TYPE = TwistyPuzzles::Edge

      def goal_badness
        2.5
      end

      def edge_combinations
        PART_TYPE::ELEMENTS.map do |c|
          c.rotations.min
        end.uniq.sort.combination(2)
      end

      def generate_input_items
        cube_state = @training_session.solved_cube_state
        part_cycle_factory = TwistyPuzzles::StickerCycleFactory.new(@training_session.cube_size, 0)
        edge_combinations.map do |edge_pair|
          part_cycle = TwistyPuzzles::PartCycle.new(edge_pair)
          flip_sticker_cycles = part_cycle_factory.multi_twist(edge_pair)
          flipped_cube_state = flip_sticker_cycles.apply_to_dupped(cube_state)
          InputItem.new(part_cycle, flipped_cube_state)
        end
      end
    end

    # Class that generates input items for commutators.
    class CommutatorSet < PartCycleAlgSet
    end

    # Class that generates input items for corner commutators.
    class CornerCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Corner

      def generate_part_cycles
        part_cycles_for_part_type - rotations
      end

      def goal_badness
        1.5
      end
    end

    # Class that generates input items for edge commutators.
    class EdgeCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Edge

      def generate_part_cycles
        part_cycles_for_part_type - rotations
      end

      def goal_badness
        1.5
      end
    end

    # Class that generates input items for wing commutators.
    class WingCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Wing

      def generate_part_cycles
        part_cycles_for_part_type - rotations
      end

      def goal_badness
        2.0
      end
    end

    # Class that generates input items for X center commutators.
    class XCenterCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::XCenter

      def generate_part_cycles
        part_cycles_for_part_type - neighbors
      end

      def goal_badness
        4.0
      end
    end

    # Class that generates input items for T center commutators.
    class TCenterCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::TCenter

      def generate_part_cycles
        part_cycles_for_part_type - neighbors
      end

      def goal_badness
        4.0
      end
    end

    # Class that generates input items for corner parities.
    class CornerParities < PartCycleAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner
      PARITY_PART_TYPE = TwistyPuzzles::Edge

      def goal_badness
        2.0
      end

      def generate_part_cycles
        non_buffer_corners.map { |c| TwistyPuzzles::PartCycle.new([buffer, c]) }
      end
    end
  end
end
