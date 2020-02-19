# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/direction'
require 'cube_trainer/core/puzzle'
require 'cube_trainer/utils/string_helper'
require 'cube_trainer/utils/array_helper'

module CubeTrainer
  module Core
    # Base class for moves.
    class Move
      AXES = %w[y z x].freeze
      SLICE_FACES = {'E' => Face::D, 'S' => Face::F, 'M' => Face::L}.freeze
      SLICE_NAMES = SLICE_FACES.invert.freeze
      MOVE_METRICS = %i[qtm htm stm sqtm qstm].freeze

      include Utils::StringHelper
      include Utils::ArrayHelper

      def <=>(other)
        [self.class.name] + identifying_fields <=> [other.class.name] + other.identifying_fields
      end

      include Comparable

      def hash
        @hash ||= ([self.class] + identifying_fields).hash
      end

      def eql?(other)
        self.class == other.class && identifying_fields == other.identifying_fields
      end

      alias == eql?

      def identifying_fields
        raise NotImplementedError
      end

      def inverse
        fields = replace_once(identifying_fields, direction, direction.inverse)
        self.class.new(*fields)
      end

      def identity?
        direction.zero?
      end

      def self.check_move_metric(metric)
        raise ArgumentError, "Invalid move metric #{metric}." unless MOVE_METRICS.include?(metric)
      end

      def equivalent?(other, cube_size)
        decide_meaning(cube_size).equivalent_internal?(other.decide_meaning(cube_size), cube_size)
      end

      def equivalent_internal?(other, _cube_size)
        self == other
      end

      def can_swap?(other)
        is_a?(Rotation) || other.is_a?(Rotation)
      end

      # For moves A, B, returns [C, D] if they can be swapped.
      def swap(other)
        raise ArgumentError unless can_swap?(other)

        if is_a?(Rotation)
          [other.rotate_by(self), self]
        elsif other.is_a?(Rotation)
          [other, rotate_by(other)]
        else
          swap_internal(other)
        end
      end

      def swap_internal(other)
        raise NotImplementedError,
              "Not implemented for #{self}:#{self.class} and #{other}:#{other.class}."
      end

      # Cube size is needed to decide whether 'u' is a slice move (like on bigger cubes) or a fat
      # move (like on 3x3).
      def move_count(cube_size, metric = :htm)
        raise TypeError unless cube_size.is_a?(Integer)

        Move.check_move_metric(metric)
        return 0 if direction.zero?

        slice_factor = decide_meaning(cube_size).slice_move? ? 2 : 1
        direction_factor = direction.double_move? ? 2 : 1
        case metric
        when :qtm
          slice_factor * direction_factor
        when :htm
          slice_factor
        when :stm
          1
        when :qstm
          direction_factor
        when :sqtm
          direction_factor
        else
          raise
        end
      end

      def slice_move?
        raise NotImplementedError, "Not implemented for #{self}:#{self.class}."
      end

      def direction
        raise NotImplementedError
      end

      def rotate_by(_rotation)
        raise NotImplementedError
      end

      def mirror(_normal_face)
        raise NotImplementedError
      end

      # The superclass for all moves that work on the same type puzzle as the given one
      # (modulo cube size, i.e. 3x3 is the same as 4x4, but Skewb is different).
      def puzzles
        raise NotImplementedError
      end

      # Return an algorithm from cancelling this move with `other` and cancelling as much as
      # possible.
      # Note that it doesn't cancel rotations even if we theoretically could do this by using
      # uncanonical wide moves.
      # Expects prepend_xyz methods to be present. That one can return a cancelled implementation
      # or nil if nothing can be cancelled.
      def join_with_cancellation(other, cube_size)
        raise ArgumentError if (puzzles & other.puzzles).empty?

        this = decide_meaning(cube_size)
        other = other.decide_meaning(cube_size)
        method_symbol = "prepend_#{snake_case_class_name(this.class)}".to_sym
        unless other.respond_to?(method_symbol)
          raise NotImplementedError, "#{other.class}##{method_symbol} is not implemented"
        end

        maybe_alg = other.method(method_symbol).call(this, cube_size)
        if maybe_alg
          Algorithm.new(maybe_alg.moves.select { |m| m.direction.non_zero? })
        else
          Algorithm.new([self, other].select { |m| m.direction.non_zero? })
        end
      end

      # We handle the annoying inconsistency that u is a slice move for bigger cubes, but a fat
      # move for 3x3. Furthermore, M slice moves are fat m slice moves for even cubes and normal
      # m slice moves for odd cubes.
      def decide_meaning(_cube_size)
        self
      end

      # In terms of prepending, inner M slice moves are exactly like other slice moves.
      def prepend_inner_m_slice_move(other, cube_size)
        prepend_slice_move(other, cube_size)
      end
    end

    # Helper class to print various types of M slice moves.
    module MSlicePrintHelper
      def to_s
        use_face = Move::SLICE_NAMES.has_key?(@axis_face)
        axis_face = use_face ? @axis_face : @axis_face.opposite
        direction = use_face ? @direction : @direction.inverse
        slice_name = Move::SLICE_NAMES[axis_face]
        "#{slice_name}#{direction.name}"
      end
    end

    # Intermediate class for all types of moves that have an axis face and a direction, i.e. cube
    # moves and rotations.
    class AxisFaceAndDirectionMove < Move
      def initialize(axis_face, direction)
        raise TypeError, "Unsuitable axis face #{axis_face}." unless axis_face.is_a?(Face)
        raise TypeError unless direction.is_a?(CubeDirection)

        @axis_face = axis_face
        @direction = direction
      end

      attr_reader :direction, :axis_face

      def translated_direction(other_axis_face)
        case @axis_face
        when other_axis_face then @direction
        when other_axis_face.opposite then @direction.inverse
        else
          raise ArgumentError
        end
      end

      def same_axis?(other)
        @axis_face.same_axis?(other.axis_face)
      end

      def identifying_fields
        [@axis_face, @direction]
      end

      def canonical_direction
        @axis_face.is_canonical_axis_face? ? @direction : @direction.inverse
      end

      def can_swap?(other)
        super || same_axis?(other)
      end

      def swap_internal(other)
        if same_axis?(other)
          [other, self]
        else
          super
        end
      end

      def rotate_by(rotation)
        if same_axis?(rotation)
          self
        else
          rotation_neighbors = rotation.axis_face.neighbors
          face_index = rotation_neighbors.index(@axis_face) || raise
          new_axis_face =
            rotation_neighbors[(face_index + rotation.direction.value) % rotation_neighbors.length]
          fields = replace_once(identifying_fields, @axis_face, new_axis_face)
          self.class.new(*fields)
        end
      end

      def mirror(normal_face)
        if normal_face.same_axis?(@axis_face)
          fields = replace_once(replace_once(identifying_fields, @direction, @direction.inverse),
                                @axis_face, @axis_face.opposite)
          self.class.new(*fields)
        else
          inverse
        end
      end
    end

    # A rotation of a Skewb or cube.
    class Rotation < AxisFaceAndDirectionMove
      def to_s
        "#{AXES[@axis_face.axis_priority]}#{canonical_direction.name}"
      end

      def puzzles
        [Puzzle::SKEWB, Puzzle::NXN_CUBE]
      end

      def slice_move?
        false
      end

      # Returns an alternative representation of the same rotation
      def alternative
        Rotation.new(@axis_face.opposite, @direction.inverse)
      end

      def equivalent_internal?(other, _cube_size)
        [self, alternative].include?(other)
      end

      def prepend_rotation(other, _cube_size)
        return unless same_axis?(other)

        other_direction = translated_direction(other.axis_face)
        Algorithm.move(Rotation.new(@axis_face, @direction + other_direction))
      end

      def prepend_fat_m_slice_move(_other, _cube_size)
        nil
      end

      def prepend_fat_move(other, cube_size)
        unless same_axis?(other) && translated_direction(other.axis_face) == other.direction.inverse
          return
        end

        Algorithm.move(
          FatMove.new(other.axis_face.opposite, other.direction, other.inverted_width(cube_size))
        )
      end

      def prepend_slice_move(_other, _cube_size)
        nil
      end

      def move_count(_cube_size, _metric = :htm)
        0
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
        if other.is_a?(SliceMove)
          return cube_size == 3 && other.slice_index == 1 &&
                 (@axis_face == other.axis_face && @direction == other.direction ||
                  @axis_face == other.axis_face.opposite && @direction == other.direction.inverse)
        elsif other.is_a?(FatMSliceMove)
          return @axis_face == other.axis_face.opposite && @direction == other.direction.inverse
        end
        false
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
        FatMove.new(f, d, 1)
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
        if same_axis?(other) && @width == 1 && @direction == other.translated_direction(@axis_face)
          Algorithm.move(FatMove.new(@axis_face, @direction, cube_size - 1))
        elsif same_axis?(other) && @width == cube_size - 1 &&
              @direction == other.translated_direction(@axis_face).inverse
          Algorithm.move(FatMove.new(@axis_face, @direction, 1))
        end
      end

      def prepend_fat_move(other, cube_size)
        if @axis_face == other.axis_face && @width == other.width
          Algorithm.move(FatMove.new(@axis_face, @direction + other.direction, @width))
        elsif @axis_face == other.axis_face.opposite && @width + other.width == cube_size
          if @direction == other.direction.inverse
            Algorithm.move(Rotation.new(@axis_face, @direction))
          else
            move = FatMove.new(other.axis_face, other.direction + @direction, other.width)
            rotation = Rotation.new(@axis_face, @direction)
            Algorithm.new([move, rotation])
          end
        end
      end

      def prepend_slice_move(other, cube_size)
        return nil unless same_axis?(other)

        translated_direction = other.translated_direction(@axis_face)
        translated_slice_index = other.translated_slice_index(@axis_face, cube_size)
        move = case translated_slice_index
               when @width
                 return nil unless translated_direction == @direction

                 with_width(@width + 1)
               when @width - 1
                 return nil unless translated_direction == @direction.inverse

                 with_width(@width - 1)
               else
                 return nil
               end
        Algorithm.move(move)
      end
    end

    # A slice move of any slice, not necessary the middle one.
    class SliceMove < CubeMove
      def initialize(axis_face, direction, slice_index)
        super(axis_face, direction)
        raise TypeError unless slice_index.is_a?(Integer)
        raise ArgumentError unless slice_index >= 1

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

      def invert_slice_index(cube_size)
        cube_size - 1 - @slice_index
      end

      def translated_slice_index(other_axis_face, cube_size)
        case @axis_face
        when other_axis_face then @slice_index
        when other_axis_face.opposite then invert_slice_index(cube_size)
        else
          raise ArgumentError
        end
      end

      def equivalent_internal?(other, cube_size)
        return other.equivalent_internal?(self, cube_size) if other.is_a?(FatMSliceMove)
        return simplified(cube_size) == other.simplified(cube_size) if other.is_a?(SliceMove)

        false
      end

      def mirror(normal_face)
        if normal_face.same_axis?(@axis_face)
          SliceMove.new(@axis_face.opposite, @direction.inverse, @slice_index)
        else
          inverse
        end
      end

      def simplified(cube_size)
        if @slice_index >= (cube_size + 1) / 2
          SliceMove.new(@axis_face.opposite, @direction.inverse, invert_slice_index(cube_size))
        else
          self
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
        return nil unless same_axis?(other)

        # Only for 4x4, we can join two adjacent slice moves into a fat m slice move.
        this = simplified(cube_size)
        if cube_size == 4 && this.slice_index == 1 &&
           mirror(@axis_face).equivalent_internal?(other, cube_size)
          return Algorithm.move(FatMSliceMove.new(other.axis_face, other.direction))
        end

        other = other.simplified(cube_size)
        return unless this.axis_face == other.axis_face && this.slice_index == other.slice_index

        Algorithm.move(
          SliceMove.new(other.axis_face,
                        other.direction + this.translated_direction(other.axis_face),
                        other.slice_index)
        )
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

    # Base class for skewb moves.
    class SkewbMove < Move
      def initialize(axis_corner, direction)
        raise TypeError unless axis_corner.is_a?(Corner)
        raise TypeError unless direction.is_a?(SkewbDirection)

        @axis_corner = axis_corner
        @direction = direction
      end

      def puzzles
        [Puzzle::SKEWB]
      end

      attr_reader :axis_corner, :direction

      def to_s
        "#{@axis_corner}#{@direction.name}"
      end

      def slice_move?
        false
      end

      def puzzle_move
        SkewbMove
      end

      def puzzle_state_class
        SkewbState
      end

      def identifying_fields
        [@axis_corner, @direction]
      end

      def rotate_by(rotation)
        nice_face = find_only(@axis_corner.adjacent_faces) do |f|
          f.same_axis?(rotation.axis_face)
        end
        nice_direction = rotation.translated_direction(nice_face)
        nice_face_corners = nice_face.clockwise_corners
        on_nice_face_index = nice_face_corners.index { |c| c.turned_equals?(@axis_corner) }
        new_corner =
          nice_face_corners[(on_nice_face_index + nice_direction.value) % nice_face_corners.length]
        self.class.new(new_corner, @direction)
      end

      def mirror(normal_face)
        faces = @axis_corner.adjacent_faces
        replaced_face = find_only(faces) { |f| f.same_axis?(normal_face) }
        new_corner =
          Corner.between_faces(replace_once(faces, replaced_face, replaced_face.opposite))
        self.class.new(new_corner, @direction.inverse)
      end
    end

    # TODO: Get rid of this legacy class
    class FixedCornerSkewbMove
      MOVED_CORNERS = {
        'U' => Corner.for_face_symbols(%i[U L B]),
        'R' => Corner.for_face_symbols(%i[D R B]),
        'L' => Corner.for_face_symbols(%i[D F L]),
        'B' => Corner.for_face_symbols(%i[D B L])
      }.freeze
      ALL = MOVED_CORNERS.values.product(SkewbDirection::NON_ZERO_DIRECTIONS).map do |m, d|
        SkewbMove.new(m, d)
      end.freeze
    end

    # TODO: Get rid of this legacy class
    class SarahsSkewbMove
      MOVED_CORNERS = {
        'F' => Corner.for_face_symbols(%i[U R F]),
        'R' => Corner.for_face_symbols(%i[U B R]),
        'B' => Corner.for_face_symbols(%i[U L B]),
        'L' => Corner.for_face_symbols(%i[U F L])
      }.freeze
      ALL = MOVED_CORNERS.values.product(SkewbDirection::NON_ZERO_DIRECTIONS).map do |m, d|
        SkewbMove.new(m, d)
      end.freeze
    end

    # Class for parsing one move type
    class MoveTypeCreator
      def initialize(capture_keys, move_class)
        @capture_keys = capture_keys.freeze
        @move_class = move_class
      end

      def applies_to?(parsed_parts)
        parsed_parts.keys.sort == @capture_keys.sort
      end

      def create(parsed_parts)
        raise ArgumentError unless applies_to?(parsed_parts)

        fields = @capture_keys.map { |name| parsed_parts[name] }
        @move_class.new(*fields)
      end
    end

    # Parser for cube moves.
    class CubeMoveParser
      REGEXP = begin
                 axes_part = "(?<axis_name>[#{Move::AXES.join}])"
                 fat_move_part =
                   "(?<width>\\d*)(?<fat_face_name>[#{CubeConstants::FACE_NAMES.join}])w"
                 normal_move_part = "(?<face_name>[#{CubeConstants::FACE_NAMES.join}])"
                 maybe_fat_maybe_slice_move_part =
                   "(?<maybe_fat_face_maybe_slice_name>[#{CubeConstants::FACE_NAMES.join.downcase}])"
                 slice_move_part =
                   "(?<slice_index>\\d+)(?<slice_name>[#{CubeConstants::FACE_NAMES.join.downcase}])"
                 mslice_move_part = "(?<mslice_name>[#{Move::SLICE_FACES.keys.join}])"
                 move_part = "(?:#{axes_part}|" \
                             "#{fat_move_part}|" \
                             "#{normal_move_part}|" \
                             "#{maybe_fat_maybe_slice_move_part}|" \
                             "#{slice_move_part}|#{mslice_move_part})"
                 direction_names =
                   AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten
                 direction_names.sort_by! { |e| -e.length }
                 direction_part = "(?<direction>#{direction_names.join('|')})"
                 Regexp.new("#{move_part}#{direction_part}")
               end
      
      MOVE_TYPE_CREATORS = [
        MoveTypeCreator.new([:axis_face, :direction], Rotation),
        MoveTypeCreator.new([:fat_face, :direction, :width], FatMove),
        MoveTypeCreator.new([:face, :direction], FatMove),
        MoveTypeCreator.new([:maybe_fat_face_maybe_slice_face, :direction], MaybeFatMaybeSliceMove),
        MoveTypeCreator.new([:slice_face, :direction, :slice_index], SliceMove),
        MoveTypeCreator.new([:mslice_face, :direction], MaybeFatMSliceMaybeInnerMSliceMove),
      ]

      def regexp
        REGEXP
      end

      def parse_direction(direction_string)
        value = AbstractDirection::POSSIBLE_DIRECTION_NAMES.index do |ds|
          ds.include?(direction_string)
        end + 1
        CubeDirection.new(value)
      end

      def parse_axis_face(axis_face_string)
        Face::ELEMENTS[Move::AXES.index(axis_face_string)]
      end

      def parse_mslice_face(mslice_name)
        Move::SLICE_FACES[mslice_name]
      end

      def parse_width(width_string)
        width_string.empty? ? 2 : Integer(width_string)
      end

      def parse_move_part(name, value)
        case name
        when 'axis_name' then parse_axis_face(value)
        when 'width' then parse_width(value)
        when 'slice_index' then Integer(value)
        when 'fat_face_name', 'face_name' then Face.by_name(value)
        when 'maybe_fat_face_maybe_slice_name', 'slice_name'
          Face.by_name(value.upcase)
        when 'mslice_name' then
          parse_mslice_face(value)
        when 'direction' then parse_direction(value)
        else raise
        end
      end
      
      def parse_move(move_string)
        match = move_string.match(REGEXP)
        if !match || !match.pre_match.empty? || !match.post_match.empty?
          raise ArgumentError "Invalid move #{move_string}."
        end

        present_named_captures = match.named_captures.select { |n, v| !v.nil? }
        parsed_parts = present_named_captures.map do |name, string|
          key = name.sub('_name', '_face').sub('face_face', 'face').to_sym
          value = parse_move_part(name, string)
          [key, value]
        end.to_h
        MOVE_TYPE_CREATORS.each do |parser|
          return parser.create(parsed_parts) if parser.applies_to?(parsed_parts)
        end
        raise "No move type creator applies to #{parsed_parts}"
      end

      INSTANCE = CubeMoveParser.new
    end

    # Parser for Skewb moves.
    class SkewbMoveParser
      def initialize(moved_corners)
        @moved_corners = moved_corners
      end

      def regexp
        @regexp ||= begin
                      skewb_direction_names =
                        AbstractDirection::POSSIBLE_SKEWB_DIRECTION_NAMES.flatten
                      move_part = "(?:([#{@moved_corners.keys.join}])" \
                                  "([#{skewb_direction_names.join}]?))"
                      rotation_direction_names =
                        AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten
                      rotation_direction_names.sort_by! { |e| -e.length }
                      rotation_part = "(?:([#{Move::AXES.join}])" \
                                      "(#{rotation_direction_names.join('|')}))"
                      Regexp.new("#{move_part}|#{rotation_part}")
                    end
      end

      def parse_skewb_direction(direction_string)
        if AbstractDirection::POSSIBLE_DIRECTION_NAMES[0].include?(direction_string)
          SkewbDirection::FORWARD
        elsif AbstractDirection::POSSIBLE_DIRECTION_NAMES[-1].include?(direction_string)
          SkewbDirection::BACKWARD
        else
          raise ArgumentError
        end
      end

      # Parses WCA Skewb moves.
      def parse_move(move_string)
        match = move_string.match(regexp)
        if !match || !match.pre_match.empty? || !match.post_match.empty?
          raise "Invalid move #{move_string}."
        end

        skewb_move_string, direction_string, rotation, rotation_direction_string = match.captures
        if skewb_move_string
          raise unless rotation.nil? && rotation_direction_string.nil?

          axis_corner = @moved_corners[skewb_move_string]
          direction = parse_skewb_direction(direction_string)
          SkewbMove.new(axis_corner, direction)
        elsif rotation
          raise unless skewb_move_string.nil? && direction_string.nil?

          Rotation.new(CubeMoveParser::INSTANCE.parse_axis_face(rotation),
                       CubeMoveParser::INSTANCE.parse_direction(rotation_direction_string))
        else
          raise
        end
      end

      FIXED_CORNER_INSTANCE = SkewbMoveParser.new(FixedCornerSkewbMove::MOVED_CORNERS)
      SARAHS_INSTANCE = SkewbMoveParser.new(SarahsSkewbMove::MOVED_CORNERS)
    end
  end
end
