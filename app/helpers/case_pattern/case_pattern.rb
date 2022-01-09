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

  # A conjunction of two case patterns.
  class Conjunction < CasePattern
    def initialize(case_patterns)
      super()
      @case_patterns = case_patterns
    end

    def match?(casee)
      @case_patterns.all? { |p| p.match?(casee) }
    end

    def bracketed_to_s
      "(#{self})"
    end

    def to_s
      @case_patterns.map(&:bracketed_to_s).join(' & ')
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
  end

  # A part pattern that matches all parts.
  class PartWildcard < PartPattern
    def match?(_part)
      true
    end

    def part; end

    def <=>(other)
      return 0 if instance_of?(other.class)

      1
    end

    def eql?(other)
      self.class.equal?(other.class)
    end

    alias == eql?

    def hash
      [self.class].hash
    end

    def to_s
      '*'
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
      @part.turned_equals?(part)
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part.turned_equals?(other.part)
    end

    def <=>(other)
      return -1 unless instance_of?(other.class)

      @part.rotations.min <=> other.part.rotations.min
    end

    alias == eql?

    def hash
      [self.class, @part.rotations.min].hash
    end

    def to_s
      @part.to_s
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
      return -1 unless instance_of?(other.class)

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
  end

  # A pattern that matches all unsolved twists.
  class AnyUnsolvedTwist < TwistPattern
    def match?(twist)
      twist.positive?
    end

    def <=>(other)
      return 0 if instance_of?(other.class)

      1
    end

    def eql?(other)
      self.class.equal?(other.class)
    end

    alias == eql?

    def hash
      [self.class].hash
    end

    def to_s
      'any unsolved'
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

    private

    def part_patterns_rotations
      @part_patterns_rotations ||= (0...@part_patterns.length).map { |r| @part_patterns.rotate(r) }
    end

    def part_patterns_match?(part_cycle)
      return false unless part_cycle.length == @part_patterns.length

      part_patterns_rotations.any? do |r|
        r.zip(part_cycle.parts).all? { |p, q| p.match?(q) }
      end
    end
  end

  # A leaf case pattern (i.e. one that isn't a conjuction) that
  # matches the given part cycle patterns.
  class LeafCasePattern < CasePattern
    # If `ignore_same_face_center_cycles` is set,
    # center cycles that stay on the same face are ignored for matching
    # if there are non-center components.
    def initialize(part_cycle_patterns, ignore_same_face_center_cycles: true)
      super()
      @part_cycle_patterns = part_cycle_patterns
      @ignore_same_face_center_cycles = ignore_same_face_center_cycles
    end

    attr_reader :part_cycle_patterns, :ignore_same_face_center_cycles

    def match?(casee)
      raise TypeError unless casee.is_a?(Case)
      return false unless casee.part_cycles.length == @part_cycle_patterns.length

      cycle_groups = part_cycle_groups(casee)
      return false unless cycle_groups.keys.sort == part_cycle_pattern_groups.keys.sort

      cycle_groups.all? do |k, cycle_group|
        pattern_group = part_cycle_pattern_groups[k]
        pattern_group_match?(pattern_group, cycle_group)
      end
    end

    def part_cycle_groups(casee)
      ignore = @ignore_same_face_center_cycles
      casee.canonicalize(ignore_same_face_center_cycles: ignore).part_cycles.group_by do |c|
        [c.part_type.name, c.length]
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
      Conjunction.new([self, other])
    end

    def to_s
      "#{self.class.name.split('::').last}(#{@part_cycle_patterns.join(', ')}, " \
        "#{@ignore_same_face_center_cycles})"
    end

    alias bracketed_to_s to_s

    private

    def part_cycle_pattern_groups
      @part_cycle_pattern_groups ||=
        part_cycle_patterns.group_by do |p|
          [p.part_type.name, p.length]
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

    def case_pattern(*part_cycle_patterns)
      LeafCasePattern.new(part_cycle_patterns)
    end

    def specific_twist(twist)
      SpecificTwist.new(twist)
    end

    def any_unsolved_twist
      AnyUnsolvedTwist.new
    end
  end
end
