# frozen_string_literal: true

require 'cube_trainer/cube_trainer_error'
require 'cube_trainer/utils/sampling_helper'

module CubeTrainer
  module Training
    class SamplingError < CubeTrainerError
    end

    # Abstract sampler class
    class Sampler
      def random_item
        raise NotImplementedError
      end

      def ready?
        raise NotImplementedError
      end
    end

    # A sampler that consists of subsamplers and weights.
    class CombinedSampler < Sampler
      include Utils::SamplingHelper
      SubSampler = Struct.new(:subsampler, :weight)

      def initialize(subsamplers)
        subsamplers.each do |s|
          raise TypeError, "#{s.inspect} is not a subsampler." unless s.is_a?(SubSampler)
          raise TypeError unless s.weight.is_a?(Numeric)
          raise ArgumentError unless s.weight > 0.0
          raise TypeError unless s.subsampler.is_a?(Sampler)
        end
        @subsamplers = subsamplers
      end

      def random_item
        subsamplers = ready_subsamplers
        raise SamplingError if subsamplers.empty?

        sample_by(subsamplers, &:weight).subsampler.random_item
      end

      def ready_subsamplers
        @subsamplers.select { |s| s.subsampler.ready? }
      end

      def ready?
        !ready_subsamplers.empty?
      end
    end

    # A sampler that has an ordered list of subsamplers that it tries to
    # use in order.
    class PrioritizedSampler < Sampler
      def initialize(subsamplers)
        raise TypeError unless subsamplers.all? { |s| s.is_a?(Sampler) }

        @subsamplers = subsamplers
      end

      def random_item
        @subsamplers.each do |s|
          return s.random_item if s.ready?
        end
        raise
      end

      def ready?
        @subsamplers.any?(&:ready?)
      end
    end

    # An adaptive sampler that has changing weights.
    class AdaptiveSampler < Sampler
      include Utils::SamplingHelper

      def initialize(items, &get_weight)
        @items = items
        @get_weight_proc = get_weight
      end

      def random_item
        ready_items = items
        raise SamplingError if ready_items.empty?

        sample_by(ready_items, &@get_weight_proc)
      end

      def items
        @items.select { |e| @get_weight_proc.call(e).positive? }
      end

      def ready?
        !items.empty?
      end
    end
  end
end
