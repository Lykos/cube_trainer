# frozen_string_literal: true

require 'twisty_puzzles/abstract_move'
require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/cube_constants'
require 'twisty_puzzles/cube_state'

module TwistyPuzzles
  
    # Helper class to figure out information about the cancellation between two algs.
    module CancellationHelper
      include CubeConstants

      def self.swap_to_end(algorithm, index)
        new_moves = algorithm.moves.dup
        index.upto(algorithm.length - 2) do |current_index|
          obstacle_index = current_index + 1
          current = new_moves[current_index]
          obstacle = new_moves[obstacle_index]
          return nil unless current.can_swap?(obstacle)

          new_moves[current_index], new_moves[obstacle_index] = current.swap(obstacle)
        end
        Algorithm.new(new_moves)
      end

      # Possible variations of the algorithm where the last move has been swapped as much as allowed
      # (e.g. D U can swap).
      def self.cancel_variants(algorithm)
        variants = []
        algorithm.moves.each_index.reverse_each do |i|
          variant = swap_to_end(algorithm, i)
          break unless variant

          variants.push(variant)
        end
        raise if variants.empty?

        variants
      end

      # Cancel this algorithm as much as possilbe
      def self.cancel(algorithm, cube_size)
        raise TypeError unless algorithm.is_a?(Algorithm)

        CubeState.check_cube_size(cube_size)
        alg = Algorithm::EMPTY
        algorithm.moves.each do |m|
          alg = push_with_cancellation(alg, m, cube_size)
        end
        alg
      end

      def self.combine_transformations(left, right)
        left.dup.transform_values { |e| right[e] }.freeze
      end

      def self.apply_transformation_to!(transformation, face_state)
        face_state.map! { |f| transformation[f] }
      end

      TRIVIAL_CENTER_TRANSFORMATION = { U: :U, F: :F, R: :R, L: :L, B: :B, D: :D }.freeze

      def self.create_directed_transformations(basic_transformation, invert)
        twice = combine_transformations(basic_transformation, basic_transformation)
        thrice = combine_transformations(twice, basic_transformation)
        non_zero_transformations = [basic_transformation, twice, thrice]
        adjusted_non_zero_transformations =
          invert ? non_zero_transformations.reverse : non_zero_transformations
        [TRIVIAL_CENTER_TRANSFORMATION] + adjusted_non_zero_transformations
      end

      CENTER_TRANSFORMATIONS =
        begin
          x_transformation = { U: :B, F: :U, R: :R, L: :L, B: :D, D: :F }.freeze
          y_transformation = { U: :U, F: :L, R: :F, L: :B, B: :R, D: :D }.freeze
          z_transformation = { U: :R, F: :F, R: :D, L: :U, B: :B, D: :L }.freeze
          {
            U: create_directed_transformations(y_transformation, false),
            F: create_directed_transformations(z_transformation, false),
            R: create_directed_transformations(x_transformation, false),
            L: create_directed_transformations(x_transformation, true),
            B: create_directed_transformations(z_transformation, true),
            D: create_directed_transformations(y_transformation, true)
          }
        end

      def self.center_transformation(rotation)
        CENTER_TRANSFORMATIONS[rotation.axis_face.face_symbol][rotation.direction.value]
      end

      def self.rotated_center_state(rotations)
        rotations.reduce(FACE_SYMBOLS.dup) do |center_state, rotation|
          apply_transformation_to!(center_transformation(rotation), center_state)
        end
      end

      def self.combined_rotation_algs
        Rotation::NON_ZERO_ROTATIONS.collect_concat do |left|
          second_rotations =
            Rotation::NON_ZERO_ROTATIONS.reject do |e|
              e.direction.double_move? || e.same_axis?(left)
            end
          second_rotations.map { |right| Algorithm.new([left, right]) }
        end
      end

      def self.rotation_sequences
        @rotation_sequences ||=
          begin
            trivial_rotation_algs = [Algorithm::EMPTY]
            single_rotation_algs = Rotation::NON_ZERO_ROTATIONS.map { |e| Algorithm.move(e) }
            combined_rotation_algs = self.combined_rotation_algs
            rotation_algs = trivial_rotation_algs + single_rotation_algs + combined_rotation_algs
            rotation_algs.map do |alg|
              [rotated_center_state(alg.moves), alg]
            end.to_h.freeze
          end
      end

      def self.cancelled_rotations(rotations)
        center_state = rotated_center_state(rotations)
        rotation_sequences[center_state]
      end

      def self.num_tail_rotations(algorithm)
        num = 0
        algorithm.moves.reverse_each do |e|
          break unless e.is_a?(Rotation)

          num += 1
        end
        num
      end

      def self.alg_plus_cancelled_move(algorithm, move, cube_size)
        if move.is_a?(Rotation) && (tail_rotations = num_tail_rotations(algorithm)) >= 2
          Algorithm.new(algorithm.moves[0...-tail_rotations]) +
            cancelled_rotations(algorithm.moves[-tail_rotations..-1] + [move])
        else
          Algorithm.new(algorithm.moves[0...-1]) +
            algorithm.moves[-1].join_with_cancellation(move, cube_size)
        end
      end

      def self.push_with_cancellation(algorithm, move, cube_size)
        raise TypeError unless move.is_a?(AbstractMove)
        return Algorithm.move(move) if algorithm.empty?

        cancel_variants =
          cancel_variants(algorithm).map do |alg|
            alg_plus_cancelled_move(alg, move, cube_size)
          end
        cancel_variants.min_by do |alg|
          # QTM is the most sensitive metric, so we use that as the highest priority for
          # cancellations.
          # We use HTM as a second priority to make sure something like RR still gets merged into
          # R2.
          # We use the length as tertiary priority to make sure rotations get cancelled even if they
          # don't change the move count.
          [alg.move_count(cube_size, :qtm), alg.move_count(cube_size, :htm), alg.length]
        end
      end
    end
end
