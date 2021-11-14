# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles/utils'

# Active record type for parts.
class PartType < ActiveRecord::Type::String
  extend TwistyPuzzles::Utils::StringHelper
  include TwistyPuzzles::Utils::StringHelper

  SEPARATOR = ':'
  PART_TYPE_NAME_TO_CLASS = TwistyPuzzles::PART_TYPES.index_by { |e| simple_class_name(e) }.freeze

  def cast(value)
    return if value.blank?
    return value if value.is_a?(TwistyPuzzles::Part)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)
    raise ArgumentError, "Cannot determine part class of #{value}." unless value.to_s[SEPARATOR]

    raw_clazz, raw_data = value.split(SEPARATOR, 2)
    clazz = PART_TYPE_NAME_TO_CLASS[raw_clazz]
    raise ArgumentError, "Unknown part class #{raw_clazz}." unless clazz

    clazz.parse(raw_data)
  end

  def serialize(value)
    return if value.nil?

    value = cast(value) unless TwistyPuzzles::PART_TYPES.include?(value)
    "#{simple_class_name(value.class)}#{SEPARATOR}#{value}"
  end
end
