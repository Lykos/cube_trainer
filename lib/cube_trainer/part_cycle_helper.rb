# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # Module to generate part cycles that have certain meanings on the cube.
  module PartCycleHelper
    def self.part_cycles(partss)
      partss.map { |ps| TwistyPuzzles::PartCycle.new(ps) }
    end

    def rotations
      self.class::PART_TYPE::ELEMENTS.flat_map do |c|
        PartCycleHelper.part_cycles(c.rotations.permutation(2))
      end
    end

    def neighbors
      self.class::PART_TYPE::ELEMENTS.flat_map do |c|
        PartCycleHelper.part_cycles(c.neighbors.permutation(2))
      end
    end

    def buffer
      @mode.buffer
    end

    def part_cycles_for_part_type
      buffer_parts = buffer.rotations
      valid_parts = self.class::PART_TYPE::ELEMENTS - buffer_parts
      rotation_parts = rotations.map(&:parts)
      valid_parts.permutation(2).filter_map do |ps|
        next if rotation_parts.include?(ps)

        TwistyPuzzles::PartCycle.new([buffer] + ps)
      end
    end
  end
end
