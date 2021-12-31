module CubeTrainer
module Training
  class CasePattern
    def match?(casee)
      raise NotImplementedError
    end
  end

  class Conjunction < CasePattern
    def initialize(case_patterns)
      @case_patterns = case_patterns
    end

    def match?(casee)
      @case_patterns.all? { |p| p.match?(casee) }
    end
  end

  class PartPattern
    include Comparable

    def <=>(other)
      raise NotImplementedError
    end

    def part
      raise NotImplementedError
    end

    def match?(part)
      raise NotImplementedError
    end
  end

  class PartWildcard < PartPattern
    def match?(part)
      true
    end

    def part; end

    def <=>(other)
      [self.class.name] <=> [other.class.name]
    end

    def eql?(other)
      self.class.equal?(other.class)
    end

    alias == eql?

    def hash
      [self.class].hash
    end

  end

  class SpecificPart < PartPattern
    def initialize(part)
      raise TypeError unless part.is_a?(TwistyPuzzles::Part)

      @part = part
    end

    attr_reader :part

    def match?(part)
      @part.turned_equals?(part)
    end

    def <=>(other)
      [self.class.name, @part] <=> [other.class.name, part]
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part.turned_equals?(other.part)
    end

    alias == eql?

    def hash
      [self.class, @part.rotations.min].hash
    end
  end

  class PartCyclePattern
    include Comparable

    def initialize(part_type, part_patterns, twist = 0)
      raise TypeError unless part_type.is_a?(Class)
      raise TypeError unless part_patterns.is_a?(Array) && part_patterns.all?(PartPattern)
      raise TypeError unless twist.is_a?(Integer)
      raise ArgumentError if twist.negative? || twist >= part_type::ELEMENTS.first.rotations.length

      @part_type = part_type
      @part_patterns = part_patterns
      @twist = twist
    end

    attr_reader :part_type, :part_patterns, :twist

    def match?(part_cycle)
      raise TypeError unless part_cycle.is_a?(TwistyPuzzles::PartCycle)

      part_cycle.part_type == @part_type &&
        part_patterns_match?(part_cycle) &&
        part_cycle.twist == @twist
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        @part_type == other.part_type &&
        @part_patterns.sort == other.part_patterns.sort &&
        @twist == other.twist
    end

    def length
      @part_patterns.length
    end

    alias == eql?

    def hash
      [self.class, @part_type, @part_patterns.sort, @twist].hash
    end

    def <=>(other)
      [@part_type.name, @part_patterns, @twist] <=> [other.part_type.name, other.part_patterns, other.twist]
    end

    private

    def part_patterns_match?(part_cycle)
      return false unless part_cycle.length == @part_patterns.length

      (0...@part_patterns.length).any? do |r|
        @part_patterns.rotate(r).zip(part_cycle.parts).all? { |p, q| p.match?(q) }
      end
    end
  end

  class ConcreteCasePattern < CasePattern
  def initialize(part_cycle_patterns, ignore_same_face_center_cycles: true)
    @part_cycle_patterns = part_cycle_patterns
    @ignore_same_face_center_cycles = ignore_same_face_center_cycles
  end

  attr_reader :part_cycle_patterns, :ignore_same_face_center_cycles

  def match?(casee)
    raise TypeError unless casee.is_a?(Case)
    return false unless casee.part_cycles.length == @part_cycle_patterns.length

    ignore = @ignore_same_face_center_cycles
    part_cycle_groups = casee.canonicalize(ignore_same_face_center_cycles: ignore).part_cycles.group_by { |c| [c.part_type.name, c.length, c.twist] }
    return false unless part_cycle_groups.keys.sort == part_cycle_pattern_groups.keys.sort

    part_cycle_groups.all? do |k, part_cycle_group|
      pattern_group = part_cycle_pattern_groups[k]
      pattern_group_match?(pattern_group, part_cycle_group)
    end
  end

  def eql?(other)
    self.class.equal?(other.class) && @part_cycle_patterns.sort == other.part_cycle_patterns.sort && @ignore_same_face_center_cycles == other.ignore_same_face_center_cycles
  end

  alias == eql?

  def hash
    [self.class, @part_cycle_patterns.sort, @ignore_same_face_center_cycles].hash
  end

  def &(other)
    Conjunction.new([self, other])
  end

  private

  def part_cycle_pattern_groups
    @part_cycle_pattern_groups ||= part_cycle_patterns.group_by { |p| [p.part_type.name, p.length, p.twist] }
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

module CasePatternDsl
def wildcard
  PartWildcard.new
end

def specific_part(part)
  SpecificPart.new(part)
end

def part_cycle_pattern(part_type, *part_patterns, twist: 0)
  PartCyclePattern.new(part_type, part_patterns, twist)
end

def case_pattern(*part_cycle_patterns)
  ConcreteCasePattern.new(part_cycle_patterns)
end
end
end
end
