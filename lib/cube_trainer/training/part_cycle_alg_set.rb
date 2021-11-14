# frozen_string_literal: true

require 'cube_trainer/part_cycle_helper'
require 'cube_trainer/buffer_helper'
require 'cube_trainer/training/input_sampler'
require 'cube_trainer/training/input_item'

module CubeTrainer
  module Training
    # Class that generates input items for items that can be represented by a sequence of parts.
    class PartCycleAlgSet
      include PartCycleHelper

      def initialize(mode)
        @mode = mode
      end

      def solved_cube_state
        @mode.solved_cube_state
      end

      def input_sampler
        InputSampler.new(input_items, @mode)
      end

      def goal_badness
        raise NotImplementedError
      end

      def generate_input_items
        generate_part_cycles.map { |e| InputItem.new(e) }
      end

      # If restrict_parts is not nil, only commutators for those parts are used.
      # TODO: Move this to somewhere else
      def restricted_input_items
        if @mode.restrict_parts.present?
          generate_input_items.select do |p|
            p.representation.contains_any_part?(@mode.restrict_parts)
          end
        else
          generate_input_items
        end
      end

      def input_items
        @input_items ||=
          restricted_input_items.reject do |p|
            p.representation.contains_any_part?(@mode.exclude_parts)
          end
      end

      def generate_part_cycles
        raise NotImplementedError
      end

      def hinter
        raise NotImplementedError
      end
    end
  end
end
