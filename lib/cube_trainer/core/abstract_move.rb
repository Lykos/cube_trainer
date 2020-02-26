# frozen_string_literal: true

require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/cube'
require 'cube_trainer/utils/string_helper'
require 'cube_trainer/utils/array_helper'

module CubeTrainer
  module Core
    # Base class for moves.
    class AbstractMove
      include Comparable
      include Utils::StringHelper
      include Utils::ArrayHelper
      AXES = %w[y z x].freeze
      # rubocop:disable Style/StringHashKeys
      SLICE_FACES = { 'E' => Face::D, 'S' => Face::F, 'M' => Face::L }.freeze
      # rubocop:enable Style/StringHashKeys
      SLICE_NAMES = SLICE_FACES.invert.freeze
      MOVE_METRICS = %i[qtm htm stm sqtm qstm].freeze

      def <=>(other)
        [self.class.name] + identifying_fields <=> [other.class.name] + other.identifying_fields
      end

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
          [other.rotate_by(self.inverse), self]
        elsif other.is_a?(Rotation)
          [other, rotate_by(other.inverse)]
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

        AbstractMove.check_move_metric(metric)
        return 0 if direction.zero?

        slice_factor = decide_meaning(cube_size).slice_move? ? 2 : 1
        direction_factor = direction.double_move? ? 2 : 1
        move_count_internal(metric, slice_factor, direction_factor)
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
      # Note that it doesn't cancel rotations with moves even if we theoretically could do this by
      # using uncanonical wide moves.
      # Expects prepend_xyz methods to be present. That one can return a cancelled implementation
      # or nil if nothing can be cancelled.
      def join_with_cancellation(other, cube_size)
        raise ArgumentError if (puzzles & other.puzzles).empty?

        maybe_alg = prepend_to(other, cube_size)
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

      private

      def move_count_internal(metric, slice_factor, direction_factor)
        case metric
        when :qtm then slice_factor * direction_factor
        when :htm then slice_factor
        when :stm then 1
        when :qstm then direction_factor
        when :sqtm then direction_factor
        else raise ArgumentError, "Invalid move metric #{metric.inspect}."
        end
      end

      def prepend_to(other, cube_size)
        this = decide_meaning(cube_size)
        other = other.decide_meaning(cube_size)
        method_symbol = "prepend_#{snake_case_class_name(this.class)}".to_sym
        unless other.respond_to?(method_symbol)
          raise NotImplementedError, "#{other.class}##{method_symbol} is not implemented"
        end

        other.method(method_symbol).call(this, cube_size)
      end
    end
  end
end
