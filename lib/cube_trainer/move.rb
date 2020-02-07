require 'cube_trainer/cube'
require 'cube_trainer/string_helper'
require 'cube_trainer/cube_constants'
require 'cube_trainer/cube_state'
require 'cube_trainer/reversible_applyable'
require 'cube_trainer/direction'
require 'cube_trainer/array_helper'
require 'cube_trainer/puzzle'

module CubeTrainer

  class Move

    AXES = ['y', 'z', 'x']
    SLICES = ['E', 'S', 'M']
    MOVE_METRICS = [:qtm, :htm, :stm, :sqtm, :qstm]

    include StringHelper
    include ArrayHelper

    def <=>(other)
      class_cmp = self.class.equal?(other.class)
      if class_cmp == 0
        identifying_fields <=> other.identifying_fields
      else
        class_cmp
      end
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

    def self.check_move_metric(metric)
      raise ArgumentError, "Invalid move metric #{metric}." unless MOVE_METRICS.include?(metric)    
    end

    def equivalent?(other, cube_size)
      decide_meaning(cube_size).equivalent_internal?(other.decide_meaning(cube_size))
    end

    def equivalent_internal?(other, cube_size)
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
        [other, self.rotate_by(other)]
      else
        swap_internal(other)
      end
    end

    def swap_internal(other)
      raise NotImplementedError, "Not implemented for #{self}:#{self.class} and #{other}:#{other.class}."
    end

    # Cube size is needed to decide whether 'u' is a slice move (like on bigger cubes) or a fat move (like on 3x3).
    def move_count(cube_size, metric=:htm)
      raise TypeError unless cube_size.is_a?(Integer)
      Move.check_move_metric(metric)
      return 0 if direction.is_zero?
      slice_factor = if decide_meaning(cube_size).is_slice_move? then 2 else 1 end
      direction_factor = if direction.is_double_move? then 2 else 1 end
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

    def is_slice_move?
      raise NotImplementedError
    end

    def direction
      raise NotImplementedError
    end

    def rotate_by(rotation)
      raise NotImplementedError
    end

    def mirror(normal_face)
      raise NotImplementedError
    end
    
    # The superclass for all moves that work on the same type puzzle as the given one (modulo cube size, i.e. 3x3 is the same as 4x4, but Skewb is different).
    def puzzles
      raise NotImplementedError
    end

    # Return an algorithm from cancelling this move with `other` and cancelling as much as possible.
    # Note that it doesn't cancel rotations even if we theoretically could do this by using uncanonical wide moves.
    # Expects prepend_xyz methods to be present. That one can return a cancelled implementation and nil if nothing can be cancelled.
    def join_with_cancellation(other, cube_size)
      raise ArgumentError if (puzzles & other.puzzles).empty?
      this = self.decide_meaning(cube_size)
      other = other.decide_meaning(cube_size)
      method_symbol = "prepend_#{snake_case_class_name(this.class)}".to_sym
      unless other.respond_to?(method_symbol)
        raise NotImplementedError, "#{other.class}##{method_symbol} is not implemented"
      end
      maybe_alg = other.method(method_symbol).call(this, cube_size)
      if maybe_alg
        Algorithm.new(maybe_alg.moves.select { |m| m.direction.is_non_zero? })
      else
        Algorithm.new([self, other].select { |m| m.direction.is_non_zero? })
      end
    end

    include ReversibleApplyable

    def apply_to(state)
      raise NotImplementedError
    end

    # We handle the annoying inconsistency that u is a slice move for bigger cubes, but a fat move for 3x3.
    # Furthermore, M slice moves are fat m slice moves for even cubes and normal m slice moves for odd cubes.
    def decide_meaning(cube_size)
      self
    end

    # In terms of prepending, inner M slice moves are exactly like other slice moves.
    def prepend_inner_m_slice_move(other, cube_size)
      prepend_slice_move(other, cube_size)
    end

  end

  module MSlicePrintHelper
    def to_s
      slice_name = Move::SLICES[@axis_face.axis_priority]
      broken_direction = slice_name == 'S' ? canonical_direction : canonical_direction.inverse
      "#{slice_name}#{broken_direction.name}"
    end
  end

  # Intermediate class for all types of moves that have an axis face and a direction, i.e. cube moves and rotations.
  class AxisFaceAndDirectionMove < Move

    def initialize(axis_face, direction)
      raise TypeError unless axis_face.is_a?(Face)
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
        new_axis_face = rotation_neighbors[(face_index + rotation.direction.value) % rotation_neighbors.length]
        fields = replace_once(identifying_fields, @axis_face, new_axis_face)
        self.class.new(*fields)
      end
    end

    def mirror(normal_face)
      if normal_face.same_axis?(@axis_face)
        fields = replace_once(replace_once(identifying_fields, @direction, @direction.inverse), @axis_face, @axis_face.inverse)
        self.class.new(*fields)
      else
        inverse
      end
    end
    
  end

  class Rotation < AxisFaceAndDirectionMove

    def to_s
      "#{AXES[@axis_face.axis_priority]}#{canonical_direction.name}"
    end

    def puzzles
      [Puzzle::SKEWB, Puzzle::NXN_CUBE]
    end

    def apply_to(cube_or_skewb_state)
      cube_or_skewb_state.apply_rotation(self)
    end
    
    def apply_to_cube(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      0.upto(cube_state.n - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
      cube_state.rotate_face(@axis_face.opposite, @direction.inverse)
    end

    def top_corner_cycles
      cycle = @axis_face.clockwise_corners
      (0...Corner::FACES).map do |rotation|
        cycle.map { |c| SkewbCoordinate.for_corner(c.rotate_by(rotation)) }
      end      
    end

    def skewb_center_cycle
      @axis_face.neighbors.map { |f| SkewbCoordinate.for_center(f) }
    end

    def skewb_cycles
      @skewb_cycles ||= [skewb_center_cycle] + self.top_corner_cycles + alternative.top_corner_cycles.map { |c| c.reverse }
    end

    def apply_to_skewb(skewb_state)
      raise TypeError unless skewb_state.is_a?(SkewbState)
      skewb_cycles.each do |c|
        skewb_state.apply_4sticker_cycle(c, @direction)
      end
    end

    def is_slice_move?
      false
    end

    # Returns an alternative representation of the same rotation
    def alternative
      Rotation.new(@axis_face.opposite, @direction.inverse)
    end

    def equivalent_internal?(other, cube_size)
      other == alternative || super
    end

    def prepend_rotation(other, cube_size)
      if same_axis?(other)
        other_direction = translate_direction(other.axis_face)
        Algorithm.move(FatMSliceMove.new(@axis_face, @direction + other_direction))
      end
    end

    def prepend_fat_m_slice_move(other, cube_size)
      nil
    end

    def prepend_fat_move(other, cube_size)
      if same_axis?(other) && translated_direction(other.axis_face) == other.direction.inverse
        Algorithm.move(FatMove.new(other.axis_face.opposite, other.direction, other.inverted_width(cube_size)))
      end
    end

    def prepend_slice_move(other, cube_size)
      nil
    end

    def move_count(cube_size, metric=:htm)
      0
    end
  end

  class CubeMove < AxisFaceAndDirectionMove
    
    def puzzles
      [Puzzle::NXN_CUBE]
    end

    def apply_to(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      decide_meaning(cube_state.n).apply_to_internal(cube_state)
    end

    def apply_to_internal(cube_state)
      raise NotImplementedError
    end
    
  end

  class FatMSliceMove < CubeMove

    def apply_to_internal(cube_state)
      raise ArgumentError unless cube_state.n % 2 == 0
      1.upto(cube_state.n - 2) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
    end

    include MSlicePrintHelper

    def prepend_rotation(other, cube_size)
      nil
    end
    
    def prepend_fat_m_slice_move(other, cube_size)
      if same_axis?(other)
        other_direction = translate_direction(other.axis_face)
        Algorithm.move(FatMSliceMove.new(@axis_face, @direction + other_direction))
      end
    end

    def prepend_fat_move(other, cube_size)
      # Note that changing the order is safe because that method returns nil if no cancellation can be performed.
      other.prepend_fat_m_slice_move(self, cube_size)
    end

    def prepend_slice_move(other, cube_size)
      nil
    end

    def is_slice_move_internal?
      true
    end

    def equivalent_internal?(other, cube_size)
      if cube_size == 3 && other.is_a?(SliceMove) && @axis_face == other.axis_face && @direction == other.direction && other.slice_index == 1
        return true
      elsif other.is_a?(FatMSliceMove) && @axis_face == other.axis_face.opposite && @direction = other.direction.opposite
        return true
      end
      super
    end

  end

  class MaybeFatMSliceMaybeInnerMSliceMove < CubeMove

    include MSlicePrintHelper
  
    # For even layered cubes, m slice moves are meant as very fat moves where only the outer layers stay.
    # For odd layered cubes, we only move the very middle.
    def decide_meaning(cube_size)
      if cube_size % 2 == 0
        FatMSliceMove.new(@axis_face, @direction)
      else
        InnerMSliceMove.new(@axis_face, @direction, cube_size / 2)
      end
    end

  end
  
  class FatMove < CubeMove

    def initialize(axis_face, direction, width=1)
      super(axis_face, direction)
      raise TypeError unless width.is_a?(Integer)
      raise ArgumentError, "Invalid width #{width} for fat move." unless width >= 1
      @width = width
    end

    OUTER_MOVES = Face::ELEMENTS.product(CubeDirection::NON_ZERO_DIRECTIONS).map { |f, d| FatMove.new(f, d, 1) }
  
    attr_reader :width
  
    def identifying_fields
      super + [@width]
    end
  
    def to_s
      "#{if @width > 1 then @width else '' end}#{@axis_face.name}#{if @width > 1 then 'w' else '' end}#{@direction.name}"
    end
  
    def apply_to_internal(cube_state)
      raise ArgumentError if @width >= cube_state.n
      0.upto(@width - 1) do |s|
        cube_state.rotate_slice(@axis_face, s, @direction)
      end
      cube_state.rotate_face(@axis_face, @direction)
    end

    def is_slice_move?
      false
    end

    def with_width(width)
      FatMove.new(@axis_face, @direction, width)
    end

    def inverted_width(cube_size)
      cube_size - @width
    end

    def prepend_rotation(other, cube_size)
      # Note that changing the order is safe because that method returns nil if no cancellation can be performed.
      other.prepend_fat_move(self, cube_size)
    end
    
    def prepend_fat_m_slice_move(other, cube_size)
      if same_axis?(other) && @width == 1 && @direction == other.translate_direction(@axis_face)
        Algorithm.move(FatMove.new(@axis_face, @direction, cube_size.n - 1))
      elsif same_axis?(other) && @width == cube_size.n - 1 && @direction == other.translate_direction(@axis_face).inverse
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
      move = case other.slice_index
             when @width
               return nil unless translated_direction == @direction
               with_width(@width + 1)
             when @width - 1
               return nil unless translated_direction == @direction.inverse
               with_width(@width - 1)
             end
      Algorithm.move(move)
    end
    
  end

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
      "#{@slice_index}#{@axis_face.name.downcase}#{@direction.name}"
    end

    def apply_to_internal(cube_state)
      cube_state.rotate_slice(@axis_face, @slice_index, @direction)
    end
    
    def is_slice_move?
      true
    end

    def invert_slice_index(cube_size)
      cube_size - 1 - @slice_index
    end

    def equivalent_internal?(other, cube_size)
      if other.is_a?(FatMSliceMove)
        return other.equivalent_internal?(self)
      elsif other.is_a?(SliceMove) && simplified(cube_size) == other.simplified(cube_size)
        return true
      end
      super
    end

    def mirror(normal_face)
      if normal_face.same_axis?(@axis_face)
        SliceMove.new(@axis_face.opposite, @direction.inverse, @slice_index)
      else
        inverse
      end
    end

    def simplified(cube_size)
      if @slice_index > cube_size / 2
        SliceMove.new(@axis_face.opposite, @direction.inverse, invert_slice_index(cube_size))
      else
        self
      end
    end

    def prepend_rotation(other, cube_size)
      nil
    end

    def prepend_fat_m_slice_move(other, cube_size)
      nil
    end

    def prepend_fat_move(other, cube_size)
      # Note that changing the order is safe because that method returns nil if no cancellation can be performed.
      other.prepend_slice_move(self, cube_size)
    end

    def prepend_slice_move(other, cube_size)
      return nil unless same_axis?(other)
      # Only for 4x4, we can join two adjacent slice moves into a fat m slice move.
      this = simplified(cube_size)
      if cube_size == 4 && this.slice_index == 1 && mirror(@axis_face).equivalent_internal?(other)
        Algorithm.move(FatMSliceMove.new(other.axis_face, other.direction))
      else
        other = other.simplified(cube_size)
        if this.axis_face == other.axis_face && this.slice_index == other.slice_index
          Algorithm.move(SliceMove.new(other.axis_face, other.direction + this.translate_direction(other.axis_face), other.slice_index))
        end
      end
    end

  end

  class InnerMSliceMove < SliceMove

    include MSlicePrintHelper

    def apply_to_internal(cube_state)
      raise ArgumentError unless cube_state.n % 2 == 1
      raise ArgumentError unless cube_state.n / 2 == @slice_index
      super
    end
    
  end


  # Not that this represents a move that is written as 'u' which is a slice move on bigger cubes but a fat move on 3x3...
  class MaybeFatMaybeSliceMove < CubeMove
  
    # We handle the annoying inconsistency that u is a slice move for bigger cubes, but a fat move for 3x3.
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

    def is_slice_move?
      false
    end

    def puzzle_move
      SkewbMove
    end

    def puzzle_state_class
      SkewbState
    end

    def twisted_corner_cycle
      @axis_corner.rotations.map { |r| SkewbCoordinate.for_corner(r) }
    end

    def center_cycle
      @axis_corner.adjacent_faces.map { |f| SkewbCoordinate.for_center(f) }
    end

    def outer_moved_corner_cycle
      faces = @axis_corner.adjacent_faces
      faces.each_index.map do |i|
        new_faces = faces.rotate(i)
        new_faces[0] = new_faces[0].opposite
        Corner.between_faces(new_faces)
      end
    end

    def moved_corner_cycles
      cycle = outer_moved_corner_cycle
      (0...Corner::FACES).map do |rotation|
        cycle.map { |c| SkewbCoordinate.for_corner(c.rotate_by(rotation)) }
      end
    end

    def cycles
      @cycles ||= [twisted_corner_cycle, center_cycle] + moved_corner_cycles
    end

    def identifying_fields
      [@axis_corner, @direction]
    end

    def rotate_by(rotation)
      nice_face = only([rotation.axis_face, rotation.axis_face.opposite].select { |f| @axis_corner.face_symbols.include?(f.face_symbol) })
      nice_direction = rotation.translated_direction(nice_face)
      corners = nice_face.clockwise_corners
      new_corner = corners[(corners.index(@axis_corner) + nice_direction.value) % corners.length]
      self.class.new(new_corner, @direction)
    end
    
    def mirror(normal_face)
      faces = @axis_corner.adjacent_faces
      replaced_face = only(faces.select { |f| f.same_axis?(normal_face) })
      new_corner = Corner.between_faces(replace_once(faces, replaced_face, replaced_face.opposite))
      self.class.new(new_corner, @direction.inverse)
    end
    
    def apply_to(skewb_state)
      raise TypeError unless skewb_state.is_a?(SkewbState)
      return skewb_state.twist_corner(@axis_corner, @direction)
      cycles.each do |c|
        case @direction
        when SkewbDirection::FORWARD
          skewb_state.apply_sticker_cycle(c)
        when SkewbDirection::BACKWARD
          skewb_state.apply_sticker_cycle(c.reverse)
        else
          raise ArgumentError
        end
      end
    end
  end

  # TODO Get rid of this legacy class
  class FixedCornerSkewbMove
    MOVED_CORNERS = {
      'U' => Corner.for_face_symbols([:U, :L, :B]),
      'R' => Corner.for_face_symbols([:D, :R, :B]),
      'L' => Corner.for_face_symbols([:D, :F, :L]),
      'B' => Corner.for_face_symbols([:D, :B, :L]),
    }
    ALL = MOVED_CORNERS.values.product(SkewbDirection::NON_ZERO_DIRECTIONS).map { |m, d| SkewbMove.new(m, d) }
  end

  # TODO Get rid of this legacy class
  class SarahsSkewbMove
    MOVED_CORNERS = {
      'F' => Corner.for_face_symbols([:U, :R, :F]),
      'R' => Corner.for_face_symbols([:U, :B, :R]),
      'B' => Corner.for_face_symbols([:U, :L, :B]),
      'L' => Corner.for_face_symbols([:U, :F, :L]),
    }
    ALL = MOVED_CORNERS.values.product(SkewbDirection::NON_ZERO_DIRECTIONS).map { |m, d| SkewbMove.new(m, d) }
  end
  
  class CubeMoveParser
    REGEXP = begin
               axes_part = "([#{Move::AXES.join}])"
               fat_move_part = "(\\d*)([#{CubeConstants::FACE_NAMES.join}])w"
               normal_move_part = "([#{CubeConstants::FACE_NAMES.join}])"
               small_move_part = "([#{CubeConstants::FACE_NAMES.join.downcase}])"
               slice_move_part = "([#{Move::SLICES.join}])"
               move_part = "(?:#{axes_part}|#{fat_move_part}|#{normal_move_part}|#{small_move_part}|#{slice_move_part})"
               direction_part = "(#{AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten.sort_by { |e| -e.length }.join("|")})"
               Regexp.new("#{move_part}#{direction_part}")
             end

    def regexp
      REGEXP
    end

    def parse_direction(direction_string)
      value = AbstractDirection::POSSIBLE_DIRECTION_NAMES.index { |ds| ds.include?(direction_string) } + 1
      CubeDirection.new(value)
    end

    def parse_axis_face(axis_face_string)
      Face::ELEMENTS[Move::AXES.index(axis_face_string)]
    end
  
    def parse_move(move_string)
      match = move_string.match(REGEXP)
      raise ArgumentError "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
      rotation, width, fat_face_name, face_name, slice_name, mslice_name, direction_string = match.captures
      direction = parse_direction(direction_string)
      if rotation
        raise unless width.nil? && fat_face_name.nil? && face_name.nil? && slice_name.nil?
        Rotation.new(parse_axis_face(rotation), direction)
      elsif fat_face_name
        raise unless rotation.nil? && face_name.nil? && slice_name.nil?
        width = if width == '' then 2 else width.to_i end
        FatMove.new(Face.by_name(fat_face_name), direction, width)
      elsif face_name
        raise unless rotation.nil? && width.nil? && fat_face_name.nil? && slice_name.nil?
        FatMove.new(Face.by_name(face_name), direction, 1)
      elsif slice_name
        raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
        MaybeFatMaybeSliceMove.new(Face.by_name(slice_name.upcase), direction)
      elsif mslice_name
        raise unless rotation.nil? && width.nil? && fat_face_name.nil? && face_name.nil?
        fixed_direction = if mslice_name == 'S' then direction else direction.inverse end
        MaybeFatMSliceMaybeInnerMSliceMove.new(Face::ELEMENTS[Move::SLICES.index(mslice_name)], fixed_direction)
      else
        raise
      end
    end

    INSTANCE = CubeMoveParser.new
  end

  class SkewbMoveParser
    def initialize(moved_corners)
      @moved_corners = moved_corners
    end
      
    def regexp
      @regexp ||= begin
                    move_part = "(?:([#{@moved_corners.keys.join}])([#{AbstractDirection::POSSIBLE_SKEWB_DIRECTION_NAMES.flatten.join}]?))"
                    rotation_part = "(?:([#{Move::AXES.join}])(#{AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten.sort_by { |e| -e.length }.join("|")}))"
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
      raise "Invalid move #{move_string}." if !match || !match.pre_match.empty? || !match.post_match.empty?
      
      skewb_move_string, direction_string, rotation, rotation_direction_string = match.captures
      if skewb_move_string
        raise unless rotation.nil? && rotation_direction_string.nil?
        axis_corner = @moved_corners[skewb_move_string]
        direction = parse_skewb_direction(direction_string)
        SkewbMove.new(axis_corner, direction)
      elsif rotation
        raise unless skewb_move_string.nil? && direction_string.nil?
        Rotation.new(CubeMoveParser::INSTANCE.parse_axis_face(rotation), CubeMoveParser::INSTANCE.parse_direction(rotation_direction_string))
      else
        raise
      end
    end

    FIXED_CORNER_INSTANCE = SkewbMoveParser.new(FixedCornerSkewbMove::MOVED_CORNERS)
    SARAHS_INSTANCE = SkewbMoveParser.new(SarahsSkewbMove::MOVED_CORNERS)
  end

end
