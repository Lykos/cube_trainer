# frozen_string_literal: true

require 'cube_trainer/core/abstract_move'
require 'cube_trainer/core/axis_face_and_direction_move'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/puzzle'

module CubeTrainer
  module Core
    # Helper class to print various types of M slice moves.
    module MSlicePrintHelper
      def to_s
        use_face = AbstractMove::SLICE_NAMES.key?(@axis_face)
        axis_face = use_face ? @axis_face : @axis_face.opposite
        direction = use_face ? @direction : @direction.inverse
        slice_name = AbstractMove::SLICE_NAMES[axis_face]
        "#{slice_name}#{direction.name}"
      end
    end

    # Base class for cube moves.
    class CubeMove < AxisFaceAndDirectionMove
      def puzzles
        [Puzzle::NXN_CUBE]
      end
    end

    # A fat M slice move that moves everything but the outer layers.
    class FatMSliceMove < CubeMove
      include MSlicePrintHelper

      def prepend_rotation(_other, _cube_size)
        nil
      end

      def prepend_fat_m_slice_move(other, _cube_size)
        return unless same_axis?(other)

        other_direction = other.translated_direction(@axis_face)
        Algorithm.move(FatMSliceMove.new(@axis_face, @direction + other_direction))
      end

      def prepend_fat_move(other, cube_size)
        # Note that changing the order is safe because that method returns nil if no cancellation
        # can be performed.
        other.prepend_fat_m_slice_move(self, cube_size)
      end

      def prepend_slice_move(_other, _cube_size)
        nil
      end

      def slice_move?
        true
      end

      def equivalent_internal?(other, cube_size)
        case other
        when SliceMove
          return equivalent_slice_move?(other, cube_size)
        when FatMSliceMove
          return @axis_face == other.axis_face.opposite && @direction == other.direction.inverse
        end

        false
      end

      protected

      def equivalent_slice_move?(other, cube_size)
        cube_size == 3 && other.slice_index == 1 &&
          (@axis_face == other.axis_face && @direction == other.direction ||
           @axis_face == other.axis_face.opposite && @direction == other.direction.inverse)
      end
    end

    # An M slice move for which we don't know yet whether it's an inner or fat M slice move.
    class MaybeFatMSliceMaybeInnerMSliceMove < CubeMove
      include MSlicePrintHelper

      # For even layered cubes, m slice moves are meant as very fat moves where only the outer
      # layers stay.
      # For odd layered cubes, we only move the very middle.
      def decide_meaning(cube_size)
        if cube_size.even?
          FatMSliceMove.new(@axis_face, @direction)
        else
          InnerMSliceMove.new(@axis_face, @direction, cube_size / 2)
        end
      end
    end

    # A fat move with a width. For width 1, this becomes a normal outer move.
    class FatMove < CubeMove
      def initialize(axis_face, direction, width = 1)
        super(axis_face, direction)
        raise TypeError unless width.is_a?(Integer)
        raise ArgumentError, "Invalid width #{width} for fat move." unless width >= 1

        @width = width
      end

      OUTER_MOVES = Face::ELEMENTS.product(CubeDirection::NON_ZERO_DIRECTIONS).map do |f, d|
        FatMove.new(f, d)
      end.freeze

      attr_reader :width

      def identifying_fields
        super + [@width]
      end

      def to_s
        "#{@width > 2 ? @width : ''}#{@axis_face.name}#{@width > 1 ? 'w' : ''}#{@direction.name}"
      end

      def slice_move?
        false
      end

      def with_width(width)
        FatMove.new(@axis_face, @direction, width)
      end

      def inverted_width(cube_size)
        cube_size - @width
      end

      def prepend_rotation(other, cube_size)
        # Note that changing the order is safe because that method returns nil if no cancellation
        # can be performed.
        other.prepend_fat_move(self, cube_size)
      end

      def prepend_fat_m_slice_move(other, cube_size)
        if adjacent_mslice_move?(other)
          Algorithm.move(FatMove.new(@axis_face, @direction, cube_size - 1))
        elsif contained_mslice_move?(other, cube_size)
          Algorithm.move(FatMove.new(@axis_face, @direction, 1))
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def prepend_fat_move(other, cube_size)
        if same_fat_block?(other)
          merge_with_same_fat_block(other)
        elsif opposite_fat_block?(other, cube_size)
          merge_with_opposite_fat_block(other)
        elsif leaves_inner_slice_move?(other)
          Algorithm.move(inner_slice_move)
        elsif other.leaves_inner_slice_move?(self)
          Algorithm.move(other.inner_slice_move)
        elsif leaves_inner_fat_mslice_move?(other, cube_size)
          Algorithm.move(inner_fat_mslice_move(cube_size))
        elsif other.leaves_inner_fat_mslice_move?(self, cube_size)
          Algorithm.move(other.inner_fat_mslice_move(cube_size))
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def prepend_slice_move(other, cube_size)
        return unless same_axis?(other)

        translated_direction = other.translated_direction(@axis_face)
        translated_slice_index = other.translated_slice_index(@axis_face, cube_size)
        move =
          case translated_slice_index
          when @width
            return unless translated_direction == @direction

            with_width(@width + 1)
          when @width - 1
            return unless translated_direction == @direction.inverse

            with_width(@width - 1)
          else
            return
          end
        Algorithm.move(move)
      end

      protected

      def merge_with_same_fat_block(other)
        Algorithm.move(FatMove.new(@axis_face, @direction + other.direction, @width))
      end

      def merge_with_opposite_fat_block(other)
        rotation = Rotation.new(@axis_face, @direction)
        move = FatMove.new(other.axis_face, other.direction + @direction, other.width)
        Algorithm.new([move, rotation])
      end

      # The outermost slice move inside this fat move.
      def inner_slice_move
        raise ArgumentError unless @width >= 2

        SliceMove.new(@axis_face, @direction, @width - 1)
      end

      # The fat M-slice move inside this fat move.
      def inner_fat_mslice_move(cube_size)
        raise ArgumentError unless cube_size.even? && @width == cube_size - 1

        FatMSliceMove.new(@axis_face, @direction)
      end

      def contained_mslice_move?(other, cube_size)
        same_axis?(other) && @width == cube_size - 1 &&
          @direction == other.translated_direction(@axis_face).inverse
      end

      def adjacent_mslice_move?(other)
        same_axis?(other) && @width == 1 && @direction == other.translated_direction(@axis_face)
      end

      def same_fat_block?(other)
        @axis_face == other.axis_face && @width == other.width
      end

      def leaves_inner_slice_move?(other)
        @axis_face == other.axis_face && @width == other.width + 1 &&
          @direction == other.direction.inverse
      end

      def leaves_inner_fat_mslice_move?(other, cube_size)
        cube_size.even? && @axis_face == other.axis_face && @width == cube_size - 1 &&
          other.width == 1 && @direction == other.direction.inverse
      end

      def opposite_fat_block?(other, cube_size)
        @axis_face == other.axis_face.opposite && @width + other.width == cube_size
      end
    end

    # A slice move of any slice, not necessary the middle one.
    class SliceMove < CubeMove
      def initialize(axis_face, direction, slice_index)
        super(axis_face, direction)
        raise TypeError unless slice_index.is_a?(Integer)
        unless slice_index >= 1
          raise ArgumentError, "Invalid slice index #{slice_index} for slice move."
        end

        @slice_index = slice_index
      end

      attr_reader :slice_index

      def identifying_fields
        super + [@slice_index]
      end

      def to_s
        "#{@slice_index > 1 ? @slice_index : ''}#{@axis_face.name.downcase}#{@direction.name}"
      end

      def slice_move?
        true
      end

      def mirror(normal_face)
        if normal_face.same_axis?(@axis_face)
          SliceMove.new(@axis_face.opposite, @direction.inverse, @slice_index)
        else
          inverse
        end
      end

      def equivalent_internal?(other, cube_size)
        return other.equivalent_internal?(self, cube_size) if other.is_a?(FatMSliceMove)
        return simplified(cube_size) == other.simplified(cube_size) if other.is_a?(SliceMove)

        false
      end

      def translated_slice_index(other_axis_face, cube_size)
        if @slice_index >= cube_size - 1
          raise ArgumentError,
                "Slice index #{@slice_index} of #{self} is invalid for cube size #{cube_size}."
        end

        case @axis_face
        when other_axis_face then @slice_index
        when other_axis_face.opposite then invert_slice_index(cube_size)
        else raise ArgumentError
        end
      end

      def prepend_rotation(_other, _cube_size)
        nil
      end

      def prepend_fat_m_slice_move(_other, _cube_size)
        nil
      end

      def prepend_fat_move(other, cube_size)
        # Note that changing the order is safe because that method returns nil if no cancellation
        # can be performed.
        other.prepend_slice_move(self, cube_size)
      end

      def prepend_slice_move(other, cube_size)
        return unless same_axis?(other)

        # Only for 4x4, we can join two adjacent slice moves into a fat m slice move.
        this = simplified(cube_size)
        if this.can_join_to_fat_mslice?(other, cube_size)
          return Algorithm.move(FatMSliceMove.new(other.axis_face, other.direction))
        end

        other = other.simplified(cube_size)
        return unless this.same_slice?(other)

        Algorithm.move(
          SliceMove.new(
            other.axis_face,
            other.direction + this.translated_direction(other.axis_face),
            other.slice_index
          )
        )
      end

      protected

      def simplified(cube_size)
        if @slice_index >= cube_size - 1
          raise ArgumentError,
                "Slice index #{@slice_index} of #{self} is invalid for cube size #{cube_size}."
        end

        if @slice_index >= (cube_size + 1) / 2
          SliceMove.new(@axis_face.opposite, @direction.inverse, invert_slice_index(cube_size))
        else
          self
        end
      end

      def invert_slice_index(cube_size)
        cube_size - 1 - @slice_index
      end

      # Note that this is only a partial implementation of what we need internally.
      # It does NOT get all cases correctly because there might be equivalent versions of the
      # same slice move.
      def can_join_to_fat_mslice?(other, cube_size)
        cube_size == 4 && @slice_index == 1 &&
          mirror(@axis_face).equivalent_internal?(other, cube_size)
      end

      # Note that this is only a partial implementation of what we need internally.
      # It does NOT get all cases correctly because there might be equivalent versions of the
      # same slice move.
      def same_slice?(other)
        @axis_face == other.axis_face && @slice_index == other.slice_index
      end
    end

    # Inner M slice moves that move only one middle layer.
    class InnerMSliceMove < SliceMove
      include MSlicePrintHelper
    end

    # Not that this represents a move that is written as 'u' which is a slice move on bigger cubes
    # but a fat move on 3x3...
    class MaybeFatMaybeSliceMove < CubeMove
      # We handle the annoying inconsistency that u is a slice move for bigger cubes, but a fat move
      # for 3x3.
      def decide_meaning(cube_size)
        case cube_size
        when 2 then raise ArgumentError
        when 3 then FatMove.new(@axis_face, @direction, 2)
        else SliceMove.new(@axis_face, @direction, 1)
        end
      end

      def to_s
        "#{@axis_face.name.downcase}#{@direction.name}"
      end
    end
  end
end
