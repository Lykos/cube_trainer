# frozen_string_literal: true

require 'twisty_puzzles/utils'

module CasePattern
  # A pattern that matches cases. These can be used at multiple levels.
  # E.g. a pattern can be used to match
  # * all edge 3 cycles,
  # * all edge 3 cycles with buffer UF
  # * the concrete edge cycle UF UB DF
  # * all two twists
  class CasePattern
    include TwistyPuzzles::Utils::StringHelper

    def match?(casee)
      raise NotImplementedError
    end
  end

  # A case pattern that is based on a sequence of children like a disjunction or conjunction.
  class AbstractSequenceBasedCasePattern < CasePattern
    def initialize(case_patterns)
      super()
      @case_patterns = case_patterns
    end

    attr_reader :case_patterns

    def bracketed_to_s
      "(#{self})"
    end

    def to_s
      @case_patterns.map(&:bracketed_to_s).join(" #{join_symbol} ")
    end

    def eql?(other)
      self.class.equal?(other.class) && @case_patterns == other.case_patterns
    end

    alias == eql?

    def hash
      self.class.hash
    end
  end

  # A conjunction of two case patterns.
  class Conjunction < AbstractSequenceBasedCasePattern
    def match?(casee)
      @case_patterns.all? { |p| p.match?(casee) }
    end

    def join_symbol
      '&'
    end
  end

  # A disjunction of two case patterns.
  class Disjunction < AbstractSequenceBasedCasePattern
    def match?(casee)
      @case_patterns.any? { |p| p.match?(casee) }
    end

    def join_symbol
      '|'
    end
  end

  # A part pattern that either matches an individial part or all parts.
  class PartPattern
    include Comparable

    def part
      raise NotImplementedError
    end

    def <=>(other)
      raise NotImplementedError
    end

    def match?(part)
      raise NotImplementedError
    end

    def &(other)
      raise NotImplementedError
    end

    def rotate_by(number)
      raise NotImplementedError
    end
  end

  # Helper for all part patterns that have no parameter and always return the same answer.
  module ConstantPartPattern
    def part; end

    def <=>(other)
      self.class.name <=> other.class.name
    end

    def eql?(other)
      self.class.equal?(other.class)
    end

    alias == eql?

    def hash
      self.class.hash
    end

    def rotate_by(_number)
      self
    end
  end

  # A part pattern that matches nothing
  class EmptyPartPattern < PartPattern
    include ConstantPartPattern

    def match?(_part)
      false
    end

    def to_s
      '!'
    end

    def &(_other)
      self
    end
  end

  # A part pattern that matches all parts.
  class PartWildcard < PartPattern
    include ConstantPartPattern

    def match?(_part)
      true
    end

    def to_s
      '*'
    end

    def &(other)
      other
    end
  end

  # A part pattern that matches a specific.
  class SpecificPart < PartPattern
    def initialize(part)
      raise TypeError unless part.is_a?(TwistyPuzzles::Part)

      super()
      @part = part
    end

    attr_reader :part

    def match?(part)
      @part == part
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part == other.part
    end

    def <=>(other)
      class_spaceship = self.class.name <=> other.class.name
      return class_spaceship if class_spaceship != 0

      @part <=> other.part
    end

    alias == eql?

    def hash
      [self.class, @part].hash
    end

    def to_s
      @part.to_s
    end

    def &(other)
      self == other || other.is_a?(PartWildcard) ? self : EmptyPartPattern.new
    end

    def rotate_by(number)
      self.class.new(part.rotate_by(number))
    end
  end

  # A pattern that matches either individual twists or all unsolved twists.
  class TwistPattern
    include Comparable

    def <=>(other)
      raise NotImplementedError
    end

    def match?(twist)
      raise NotImplementedError
    end

    def &(other)
      raise NotImplementedError
    end
  end

  # A pattern that matches an individual twists.
  class SpecificTwist < TwistPattern
    def initialize(twist)
      raise TypeError unless twist.is_a?(Integer)
      raise ArgumentError if twist.negative?

      super()
      @twist = twist
    end

    attr_reader :twist

    def match?(twist)
      @twist == twist
    end

    def <=>(other)
      class_spaceship = self.class.name <=> other.class.name
      return class_spaceship if class_spaceship != 0

      @twist <=> other.twist
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @twist == other.twist
    end

    alias == eql?

    def hash
      [self.class, @twist].hash
    end

    def to_s
      @twist.to_s
    end

    def &(other)
      return self if self == other
      return self if @twist.positive? && other.is_a?(AnyUnsolvedTwist)

      EmptyTwistPattern.new
    end
  end

  # Helper module for twist patterns that have no parameter and always return the same answer.
  module ParameterLessTwist
    def <=>(other)
      self.class.name <=> other.class.name
    end

    def eql?(other)
      self.class.equal?(other.class)
    end

    alias == eql?

    def hash
      self.class.hash
    end
  end

  # A pattern that matches all unsolved twists.
  class AnyUnsolvedTwist < TwistPattern
    include ParameterLessTwist

    def match?(twist)
      twist.positive?
    end

    def to_s
      'any unsolved'
    end

    def &(other)
      return self if self == other
      return other if other.is_a?(SpecificTwistPattern)

      EmptyTwistPattern.new
    end
  end

  # A part pattern that matches nothing
  class EmptyTwistPattern < TwistPattern
    include ParameterLessTwist

    def match?(_twist)
      false
    end

    def to_s
      'unfulfillable'
    end

    def &(_other)
      self
    end
  end

  # A part cycle pattern that matches part cycles of a given type and
  # with a given set of fixed pieces.
  class PartCyclePattern
    include TwistyPuzzles::Utils::StringHelper
    include Comparable

    def initialize(part_type, part_patterns, twist = SpecificTwist.new(0))
      raise TypeError, "Got #{part_type} instead of a part type." unless part_type.is_a?(Class)
      raise TypeError unless part_patterns.is_a?(Array) && part_patterns.all?(PartPattern)
      raise TypeError unless twist.is_a?(TwistPattern)

      @part_type = part_type
      @part_patterns = part_patterns
      @twist = twist
    end

    attr_reader :part_type, :part_patterns, :twist

    def match?(part_cycle)
      raise TypeError unless part_cycle.is_a?(TwistyPuzzles::PartCycle)

      part_cycle.part_type == @part_type &&
        part_patterns_match?(part_cycle) &&
        @twist.match?(part_cycle.twist)
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part_type == other.part_type &&
        min_part_patterns_rotation == other.min_part_patterns_rotation &&
        @twist == other.twist
    end

    def length
      @part_patterns.length
    end

    alias == eql?

    def hash
      [self.class, @part_type, min_part_patterns_rotation, @twist].hash
    end

    def <=>(other)
      [
        @part_type.name, min_part_patterns_rotation,
        @twist
      ] <=> [other.part_type.name, other.min_part_patterns_rotation, other.twist]
    end

    def to_s
      "#{simple_class_name(self.class)}(#{simple_class_name(@part_type)}, " \
        "[#{@part_patterns.join(', ')}], #{@twist})"
    end

    def min_part_patterns_rotation
      @min_part_patterns_rotation ||= part_patterns_rotations.min
    end

    def merge_possibilities(other)
      return [] unless @part_type == other.part_type

      merged_twist = @twist & other.twist
      return [] if merged_twist.is_a?(EmptyTwistPattern)

      merge_part_patterns_possibilities =
        part_patterns_rotations.filter_map do |r|
          merged_part_patterns = r.zip(other.part_patterns).map { |a, b| a & b }

          next if merged_part_patterns.any?(EmptyPartPattern)

          merged_part_patterns
        end

      merge_part_patterns_possibilities.map do |p|
        PartCyclePattern.new(@part_type, p, merged_twist)
      end
    end

    # Both cyclic shift and per element shifts are
    def part_patterns_rotations
      @part_patterns_rotations ||=
        pointwise_rotations(cyclic_shifts)
    end

    private

    def cyclic_shifts
      (0...@part_patterns.length).map { |r| @part_patterns.rotate(r) }
    end

    def pointwise_rotations(cyclic_shifts)
      part = @part_patterns.find { |e| e.is_a?(SpecificPart) }&.part
      return cyclic_shifts unless part

      (0...part.rotations.length).flat_map do |r|
        cyclic_shifts.map do |cyclic_shift|
          cyclic_shift.map { |p| p.rotate_by(r) }
        end
      end
    end

    def part_patterns_match?(part_cycle)
      return false unless part_cycle.length == @part_patterns.length

      part_patterns_rotations.any? do |r|
        r.zip(part_cycle.parts).all? { |p, q| p.match?(q) }
      end
    end
  end

  # A case pattern that matches nothing.
  class EmptyCasePattern < CasePattern
    def match?(_casee)
      false
    end

    alias == eql?

    def to_s
      simple_class_name(self.class)
    end

    def hash
      self.class.hash
    end

    alias bracketed_to_s to_s
  end

  # A leaf case pattern (i.e. one that isn't a conjuction) that
  # matches the given part cycle patterns.
  class LeafCasePattern < CasePattern
    # If `ignore_same_face_center_cycles` is set,
    # center cycles that stay on the same face are ignored for matching
    # if there are non-center components.
    def initialize(part_cycle_patterns, ignore_same_face_center_cycles:)
      super()
      @part_cycle_patterns = part_cycle_patterns
      @ignore_same_face_center_cycles = ignore_same_face_center_cycles
    end

    attr_reader :part_cycle_patterns, :ignore_same_face_center_cycles

    def match?(casee)
      raise TypeError, "Expected Case but got #{casee.inspect}." unless casee.is_a?(Case)

      ignore = @ignore_same_face_center_cycles
      casee = casee.canonicalize(ignore_same_face_center_cycles: ignore)
      return false unless casee.part_cycles.length == @part_cycle_patterns.length

      cycle_groups = part_cycle_groups(casee)
      return false unless cycle_groups.keys.sort == part_cycle_pattern_groups.keys.sort

      cycle_groups.all? do |k, cycle_group|
        pattern_group = part_cycle_pattern_groups[k]
        pattern_group_match?(pattern_group, cycle_group)
      end
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part_cycle_patterns.sort == other.part_cycle_patterns.sort &&
        @ignore_same_face_center_cycles == other.ignore_same_face_center_cycles
    end

    alias == eql?

    def hash
      [self.class, @part_cycle_patterns.sort, @ignore_same_face_center_cycles].hash
    end

    def &(other)
      return EmptyCasePattern.new if other.is_a?(EmptyCasePattern)
      return Conjunction.new([self, other]) unless other.is_a?(LeafCasePattern)
      return EmptyCasePattern.new if part_cycle_pattern_groups.keys.sort != other.part_cycle_pattern_groups.keys.sort

      merge_groups(other)
    end

    def |(other)
      return self if other.is_a?(EmptyCasePattern)

      Disjunction.new([self, other])
    end

    def to_s
      "#{self.class.name.split('::').last}(#{@part_cycle_patterns.join(', ')}, " \
        "#{@ignore_same_face_center_cycles})"
    end

    alias bracketed_to_s to_s

    def part_cycle_pattern_groups
      @part_cycle_pattern_groups ||=
        part_cycle_patterns.group_by do |p|
          [p.part_type.name, p.length]
        end
    end

    private

    def part_cycle_groups(casee)
      ignore = @ignore_same_face_center_cycles
      casee.canonicalize(ignore_same_face_center_cycles: ignore).part_cycles.group_by do |c|
        [c.part_type.name, c.length]
      end
    end

    def merge_groups(other)
      raise ArgumentError unless @ignore_same_face_center_cycles == other.ignore_same_face_center_cycles

      merged_groups =
        part_cycle_pattern_groups.map do |k, cycle_group|
          other_cycle_group = other.part_cycle_pattern_groups[k]
          merge_cycle_groups_possibilities(cycle_group, other_cycle_group)
        end
      return EmptyCasePattern.new if merged_groups.any?(&:empty?)
      return LeafCasePattern.new(merged_groups.flatten, ignore_same_face_center_cycles: @ignore_same_face_center_cycles) if merged_groups.all? { |g| g.length == 1 }

      Conjunction.new([self, other])
    end

    def merge_cycle_groups_possibilities(cycle_group, other_cycle_group)
      return [] if cycle_group.length != other_cycle_group.length

      cycle_group.permutation.flat_map do |e|
        e.zip(other_cycle_group).flat_map do |cycle, other_cycle|
          cycle.merge_possibilities(other_cycle)
        end
      end
    end

    # Should be called for a pattern group and a part cycle group where all
    # have the same length and part type, e.g. all edge cycles of length 3.
    def pattern_group_match?(pattern_group, part_cycle_group)
      return false if pattern_group.length != part_cycle_group.length

      pattern_group.permutation.any? do |patterns|
        patterns.zip(part_cycle_group).all? { |p, q| p.match?(q) }
      end
    end
  end

  # A pattern that matches a specific case.
  # TODO: Deprecate
  class SpecificCasePattern < CasePattern
    # If `ignore_same_face_center_cycles` is set,
    # center cycles that stay on the same face are ignored for matching
    # if there are non-center components.
    def initialize(casee, ignore_same_face_center_cycles: true)
      super()
      @casee = casee
      @ignore_same_face_center_cycles = ignore_same_face_center_cycles
    end

    attr_reader :casee

    def match?(casee)
      ignore = @ignore_same_face_center_cycles
      @casee.equivalent?(casee, ignore_same_face_center_cycles: ignore)
    end

    def to_s
      "#{self.class.name.split('::').last}(#{@part_cycle_patterns.join(', ')}, " \
        "#{@ignore_same_face_center_cycles})"
    end

    alias bracketed_to_s to_s

    def eql?(other)
      self.class.equal?(other.class) &&
        @casee.equivalent?(other.casee)
      @ignore_same_face_center_cycles == other.ignore_same_face_center_cycles
    end

    alias == eql?

    def hash
      ignore = @ignore_same_face_center_cycles
      [
        self.class,
        @casee.canonicalize(ignore_same_face_center_cycles: ignore),
        @ignore_same_face_center_cycles
      ].hash
    end

    def &(other)
      Conjunction.new([self, other])
    end

    def |(other)
      Disjunction.new([self, other])
    end
  end

  # A DSL that allows to create case patterns more conveniently.
  module CasePatternDsl
    def wildcard
      PartWildcard.new
    end

    def specific_part(part)
      SpecificPart.new(part)
    end

    def part_cycle_pattern(part_type, *part_patterns, twist: SpecificTwist.new(0))
      PartCyclePattern.new(part_type, part_patterns, twist)
    end

    def case_pattern(*part_cycle_patterns, ignore_same_face_center_cycles:)
      LeafCasePattern.new(part_cycle_patterns, ignore_same_face_center_cycles: ignore_same_face_center_cycles)
    end

    def specific_twist(twist)
      SpecificTwist.new(twist)
    end

    def any_unsolved_twist
      AnyUnsolvedTwist.new
    end
  end
end
