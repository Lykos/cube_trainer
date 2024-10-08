# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/types/part_type'

# Helps controllers and models to serialize parts.
module PartHelper
  def part_serializer
    @part_serializer ||= CubeTrainer::Types::PartType.new
  end

  def part_to_simple(part)
    return if part.nil?
    raise ArgumentError unless part.is_a?(TwistyPuzzles::Part)

    { key: part_serializer.serialize(part), name: part.to_s }
  end
end
