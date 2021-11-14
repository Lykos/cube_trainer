# frozen_string_literal: true

require 'twisty_puzzles'

# Helps controllers and models to serialize parts.
module PartHelper
  def part_serializer
    @part_serializer ||= PartType.new
  end

  def part_to_simple(part)
    return if part.nil?
    raise ArgumentError unless part.is_a?(TwistyPuzzles::Part)

    { key: part_serializer.serialize(part), name: part.to_s }
  end
end
