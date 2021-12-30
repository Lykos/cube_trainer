# Active record type for a case, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This represents the abstract case independent of its solution.
class CaseType < ActiveRecord::Type::String
  extend TwistyPuzzles::Utils::StringHelper
  include TwistyPuzzles::Utils::StringHelper

  SEPARATOR = ':'

  def cast(value)
    return if value.nil?
    return value if value.is_a?(Case)
    raise TypeError unless value.is_a?(String)

    parts = value.split(SEPARATOR)
    # TODO: Get rid of this backwards compatibility logic
    parts.shift if parts.first == 'PartCycle'
    part_cycles = parts.map { |raw_data| PartCycle.from_raw_data(raw_data) }
    Case.new(part_cycles: part_cycles)
  end

  def serialize(value)
    return if value.nil?
    raise TypeError unless value.is_a?(Case)

    parts = value.part_cycles.map(&:to_raw_data)
    raise if parts.any? { |p| p.include?(SEPARATOR) }

    parts.join(SEPARATOR)
  end
end
