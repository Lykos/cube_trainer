# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This represents the abstract case independent of its solution.
# For the specific case attached to a training session with a specific solution, see TrainingCase.
class Case
  include ActiveModel::Model
  include TwistyPuzzles::Utils::StringHelper

  attr_accessor :part_cycles

  validate :validate_part_cycles

  def to_s
    "#{simple_class_name(self.class)}(part_cycles: [#{part_cycles.join(', ')}])"
  end

  # If `ignore_same_face_center_cycles` is set,
  # center cycles that stay on the same face are ignored for comparison
  # if there are non-center components.
  def equivalent?(other, ignore_same_face_center_cycles: true)
    ignore = ignore_same_face_center_cycles
    canonicalize(ignore_same_face_center_cycles: ignore).part_cycles ==
      other.canonicalize(ignore_same_face_center_cycles: ignore).part_cycles
  end

  def canonicalize(ignore_same_face_center_cycles:)
    (@canonicalize ||= {})[ignore_same_face_center_cycles] ||=
      begin
        cycles = canonicalized_cycles(ignore_same_face_center_cycles)
        canonicalized_case = Case.new(part_cycles: cycles)
        # Return self if that's correct to avoid memoization explosion.
        self == canonicalized_case ? self : canonicalized_case
      end
  end

  def inverse
    self.class.new(part_cycles: part_cycles.map(&:inverse))
  end

  def mirror(normal_face)
    self.class.new(part_cycles: part_cycles.map { |c| c.mirror(normal_face) })
  end

  def rotate_by(rotation)
    self.class.new(part_cycles: part_cycles.map { |c| c.rotate_by_rotation(rotation) })
  end

  def eql?(other)
    self.class.equal?(other.class) &&
      part_cycles == other.part_cycles
  end

  alias == eql?

  def hash
    [self.class, part_cycles].hash
  end

  def contains_any_part?(parts)
    part_cycles.any? { |c| c.contains_any_part?(parts) }
  end

  private

  def canonicalized_cycles(ignore)
    cycles = part_cycles.map(&:canonicalize).sort
    cycles.delete_if { |c| equivalent_center_cycle?(c) } if ignore
    cycles
  end

  def validate_part_cycles
    return if part_cycles.empty?

    unless part_cycles.is_a?(Array) && part_cycles.all?(TwistyPuzzles::PartCycle)
      errors.add(:part_cycles, 'have to be an array with entries of type PartCycle')
      return
    end

    validate_duplicates
    validate_twists
  end

  def validate_duplicates
    duplicate_parts = part_counts.select { |_k, v| v > 1 }.keys
    return if duplicate_parts.empty?

    errors.add(:part_cycles, "cannot have duplicate parts but found #{duplicate_parts.join(' ')}")
  end

  def validate_twists
    twisted_part_types = twist_counts.select { |_k, v| v.positive? }.keys
    return if twisted_part_types.empty?

    errors.add(:part_cycles, "twists parts don't sum up to 0 for #{twisted_part_types.join(', ')}")
  end

  def new_count_hash
    counts = {}
    counts.default = 0
    counts
  end

  def part_counts
    counts = new_count_hash
    part_cycles.each do |c|
      c.parts.each do |p|
        counts[p] += 1
      end
    end
    counts
  end

  def twist_counts
    counts = new_count_hash
    part_cycles.each do |c|
      counts[c.part_type] = (counts[c.part_type] + c.twist) % c.parts.first.rotations.length
    end
    counts
  end

  def equivalent_center_cycle?(part_cycle)
    part_cycle.part_type < TwistyPuzzles::MoveableCenter && part_cycle.parts.all? do |p|
      p.face_symbol == part_cycle.parts.first.face_symbol
    end
  end
end
