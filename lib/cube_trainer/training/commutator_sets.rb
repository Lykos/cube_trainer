# frozen_string_literal: true

require 'cube_trainer/letter_pair_helper'
require 'cube_trainer/letter_pair_sequence'
require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/disjoint_union_letter_pair_alg_set'
require 'cube_trainer/training/input_sampler'
require 'cube_trainer/training/letter_pair_alg_set'
require 'cube_trainer/training/no_hinter'
require 'cube_trainer/training/sequence_hinter'
require 'cube_trainer/training/unnamed_alg_hint_parser'
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
        self.class::PART_TYPE::ELEMENTS.reject { |c| c.turned_equals?(@mode.parsed_buffer) }
      end

      def correctly_oriented_corners
        non_buffer_corners.select do |c|
          ORIENTATION_FACES.include?(c.solved_face)
        end
      end

      def incorrectly_oriented_corners
        non_buffer_corners.reject do |c|
          ORIENTATION_FACES.include?(c.solved_face)
        end
      end
    end

    # Class that generates input items for floating corner 2 twists.
    class FloatingCorner2Twists < LetterPairAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner

      def hinter
        @hinter ||= UnnamedAlgHintParser.maybe_parse_hints('corner_twists', input_items, @mode)
      end

      def goal_badness
        2.0
      end

      def part_cycle_factory
        @part_cycle_factory ||= TwistyPuzzles::PartCycleFactory.new(@mode.cube_size, 0)
      end

      def cube_state
        @cube_state ||= @mode.solved_cube_state
      end

      def generate_input_items
        two_twists = generate_two_twists
        buffer_twist.apply_to(cube_state)
        ccw_twists = generate_one_twists(cube_state, true)
        buffer_twist.apply_to(cube_state)
        cw_twists = generate_one_twists(cube_state, false)
        two_twists + ccw_twists + cw_twists
      end

      def generate_two_twists
        correctly_oriented_corners.permutation(2).map do |c1, c2|
          twisted_corner_pair = [c1.rotate_by(1), c2.rotate_by(2)]
          letter_pair =
            LetterPair.new(twisted_corner_pair.map { |c| letter(c) }.sort)
          twist_sticker_cycles = part_cycle_factory.multi_twist([c1]) +
                                 part_cycle_factory.multi_twist([c2]).inverse
          twisted_cube_state = twist_sticker_cycles.apply_to_dupped(cube_state)
          InputItem.new(letter_pair, twisted_cube_state)
        end
      end

      def buffer_twist
        @buffer_twist ||= part_cycle_factory.multi_twist([@mode.parsed_buffer])
      end

      # The buffer of cube_state is expected to already be twisted accordingly.
      def generate_one_twists(cube_state, invert_twist)
        twist_number = invert_twist ? 2 : 1
        correctly_oriented_corners.map do |c|
          twisted_corner = c.rotate_by(twist_number)
          letter_pair = LetterPair.new([letter(twisted_corner)])
          twist_sticker_cycles = part_cycle_factory.multi_twist([c])
          twist_sticker_cycles = twist_sticker_cycles.inverse if invert_twist
          twisted_cube_state = twist_sticker_cycles.apply_to_dupped(cube_state)
          InputItem.new(letter_pair, twisted_cube_state)
        end
      end
    end

    # Class that generates input items for floating corner 2 twists and 3 twists.
    class FloatingCorner2TwistsAnd3Twists < DisjointUnionLetterPairAlgSet
      PART_TYPE = TwistyPuzzles::Corner

      def initialize(mode)
        super(
          mode,
          FloatingCorner2Twists.new(mode),
          Corner3Twists.new(mode)
        )
      end

      def buffer_coordinates
        @buffer_coordinates ||=
          TwistyPuzzles::Coordinate.solved_positions(@mode.parsed_buffer, @mode.cube_size, 0)
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
    class CornerTwistsPlusParities < LetterPairAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner
      PARITY_PART_TYPE = TwistyPuzzles::Edge

      def hinter
        corner_mode = @mode.used_mode(:corner_commutators)
        parity_mode = @mode.used_mode(:corner_parities)
        return NoHinter.new(input_items) unless corner_mode && parity_mode

        corner_hinter = CommutatorHintParser.maybe_parse_hints(PART_TYPE, corner_mode)
        parity_hinter = CommutatorHintParser.maybe_parse_hints(PART_TYPE, parity_mode)
        CornerTwistPlusParityHinter.new(
          corner_mode, parity_mode, corner_hinter, parity_hinter, mode
        )
      end

      def goal_badness
        3.0
      end

      def generate_letter_pairs
        parity_twist_combinations =
          non_buffer_corners.product(incorrectly_oriented_corners).reject do |parity, twist|
            parity.turned_equals?(twist)
          end
        parity_twist_combinations.map do |targets|
          LetterPairSequence.new(targets.map { |t| LetterPair.new([letter(t)]) })
        end
      end

      # Class that creates hints for corner twists plus parities.
      class CornerTwistPlusParityHinter < HeterogenousSequenceHinter
        include CornerTwistSetsHelper
        include TwistyPuzzles::Utils::ArrayHelper

        def initialize(corner_mode, parity_mode, corner_hinter, parity_hinter, mode)
          super(mode.cube_size, [corner_mode, parity_mode], [corner_hinter, parity_hinter])
          @letter_scheme = mode.letter_scheme
        end

        # rubocop:disable Metrics/AbcSize
        def generate_combinations(letter_sequence)
          raise ArgumentError unless letter_sequence.letter_pairs.length == 2

          parity_letter_pair = letter_sequence.letter_pairs.first
          parity_letter = only(parity_letter_pair.letters)
          twist_letter_pair = letter_sequence.letter_pairs.last
          twist_letter = only(twist_letter_pair.letters)
          twisted_part = @letter_scheme.for_letter(PART_TYPE, twist_letter)
          solved_twist_part = rotate_orientation_face_up(twisted_part)
          Array.new(TwistyPuzzles::Corner::FACES) do |rot|
            twist_entry_letter = letter(twisted_part.rotate_by(rot))
            twist_exit_letter = letter(solved_twist_part.rotate_by(rot))
            comm = LetterPair.new([parity_letter, twist_entry_letter])
            parity = LetterPair.new([twist_exit_letter])
            [comm, parity]
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end

    # Class that generates input items for corner 3 twists.
    class Corner3Twists < LetterPairAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner

      def hinter
        return NoHinter.new(input_items) unless (corner_mode = @mode.used_mode(:corner_commutators))

        corner_hinter = CommutatorHintParser.maybe_parse_hints(PART_TYPE, corner_mode)
        Corner3TwistHinter.new(corner_mode, corner_hinter, @mode)
      end

      def goal_badness
        2.5
      end

      # rubocop:disable Metrics/AbcSize
      def generate_input_items
        cube_state = @mode.solved_cube_state
        part_cycle_factory = TwistyPuzzles::PartCycleFactory.new(@mode.cube_size, 0)
        buffer_twist = part_cycle_factory.multi_twist([@mode.parsed_buffer])
        1.upto(2).collect_concat do |twist_number|
          buffer_twist.apply_to(cube_state)
          correctly_oriented_corners.combination(2).collect_concat do |c1, c2|
            twisted_corner_pair = [c1.rotate_by(twist_number), c2.rotate_by(twist_number)]
            letter_pair =
              LetterPair.new(twisted_corner_pair.map { |c| letter(c) }.sort)
            twist_sticker_cycles = part_cycle_factory.multi_twist([c1, c2])
            twist_sticker_cycles = twist_sticker_cycles.inverse if twist_number == 2
            twisted_cube_state = twist_sticker_cycles.apply_to_dupped(cube_state)
            InputItem.new(letter_pair, twisted_cube_state)
          end
        end
        # rubocop:enable Metrics/AbcSize
      end

      # Class that creates hints for corner 3 twists.
      class Corner3TwistHinter < HomogenousSequenceHinter
        include CornerTwistSetsHelper

        # Note that `mode` should be the mode for corner comms, not for corner 3 twists.
        def initialize(corner_mode, corner_hinter, mode)
          super(mode.cube_size, corner_mode, corner_hinter)
          @letter_scheme = mode.letter_scheme
        end

        def rotate_other_face_up(part)
          part.rotate_other_face_up(orientation_face(part))
        end

        def rotate_comm_target(comm, target_index, rotation)
          raise ArgumentError unless comm.length == 2
          raise ArgumentError unless [0, 1].include?(target_index)

          comm.map.with_index do |c, i|
            if i == target_index
              c.rotate_by(rotation)
            else
              c
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        def generate_directed_solutions(parts)
          raise unless parts.length == 2

          first_corner, second_corner = parts

          # We define one solution explicitly
          solution_corners = [
            # Parts for first comm
            [first_corner, second_corner],
            # Parts for second comm
            [rotate_orientation_face_up(second_corner), rotate_other_face_up(first_corner)]
          ]

          # Now we generate additional solutions by rotating both colors in one direction.
          extended_solutions =
            Array.new(TwistyPuzzles::Corner::FACES) do |rot|
              solution_corners.map do |comm|
                comm.map { |p| p.rotate_by(rot) }
              end
            end

          # Now we generate even more additional solutions by rotating the second corner of the
          # first comm and the first corner of the second comm in opposite directions.
          extended_solutions =
            TwistyPuzzles::Corner::FACES.times.collect_concat do |rot|
              extended_solutions.map do |solution|
                raise unless solution.length == 2

                first_comm, second_comm = solution
                [
                  rotate_comm_target(first_comm, 1, rot),
                  rotate_comm_target(second_comm, 0, rot)
                ]
              end
            end

          # Now we generate letter pairs
          extended_solutions.map do |s|
            s.map { |comm| LetterPair.new(comm.map { |p| letter(p) }) }
          end
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/AbcSize

        def generate_combinations(letter_pair)
          pieces = letter_pair.letters.map { |l| @letter_scheme.for_letter(PART_TYPE, l) }
          generate_directed_solutions(pieces) + generate_directed_solutions(pieces.reverse)
        end
      end
    end

    # Class that generates input items for floating edge flips.
    class FloatingEdgeFlips < LetterPairAlgSet
      PART_TYPE = TwistyPuzzles::Edge

      def hinter
        @hinter ||= UnnamedAlgHintParser.maybe_parse_hints('edge_flips', input_items, @mode)
      end

      def goal_badness
        2.5
      end

      def edge_combinations
        PART_TYPE::ELEMENTS.map do |c|
          c.rotations.min_by { |e| letter(e) }
        end.uniq.sort.combination(2)
      end

      def generate_input_items
        cube_state = @mode.solved_cube_state
        part_cycle_factory = TwistyPuzzles::PartCycleFactory.new(@mode.cube_size, 0)
        edge_combinations.map do |edge_pair|
          letter_pair = LetterPair.new(edge_pair.map { |e| letter(e) })
          flip_sticker_cycles = part_cycle_factory.multi_twist(edge_pair)
          flipped_cube_state = flip_sticker_cycles.apply_to_dupped(cube_state)
          InputItem.new(letter_pair, flipped_cube_state)
        end
      end
    end

    # Class that generates input items for commutators.
    class CommutatorSet < LetterPairAlgSet
      def hinter
        @hinter ||= CommutatorHintParser.maybe_parse_hints(self.class::PART_TYPE, @mode)
      end
    end

    # Class that generates input items for corner commutators.
    class CornerCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Corner

      def generate_letter_pairs
        letter_pairs_for_part_type - rotations
      end

      def goal_badness
        1.5
      end
    end

    # Class that generates input items for edge commutators.
    class EdgeCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Edge

      def generate_letter_pairs
        letter_pairs_for_part_type - rotations
      end

      def goal_badness
        1.5
      end
    end

    # Class that generates input items for wing commutators.
    class WingCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::Wing

      def generate_letter_pairs
        letter_pairs_for_part_type - rotations
      end

      def goal_badness
        2.0
      end
    end

    # Class that generates input items for X center commutators.
    class XCenterCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::XCenter

      def generate_letter_pairs
        letter_pairs_for_part_type - neighbors
      end

      def goal_badness
        4.0
      end
    end

    # Class that generates input items for T center commutators.
    class TCenterCommutators < CommutatorSet
      PART_TYPE = TwistyPuzzles::TCenter

      def generate_letter_pairs
        letter_pairs_for_part_type - neighbors
      end

      def goal_badness
        4.0
      end
    end

    # Class that generates input items for corner parities.
    class CornerParities < LetterPairAlgSet
      include CornerTwistSetsHelper

      PART_TYPE = TwistyPuzzles::Corner
      PARITY_PART_TYPE = TwistyPuzzles::Edge

      def hinter
        @hinter ||= UnnamedAlgHintParser.maybe_parse_hints('parities', input_items, @mode)
      end

      def goal_badness
        2.0
      end

      def generate_letter_pairs
        non_buffer_corners.map { |c| LetterPair.new([letter(c)]) }
      end
    end
  end
end
