# frozen_string_literal: true

require 'strscan'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/cube'

module CubeTrainer
  module Core
    # Base class for Commutators.
    class Commutator
      def cancellations(other, cube_size, metric = :htm)
        algorithm.cancellations(other.algorithm, cube_size, metric)
      end
    end

    # Algorithm that is used like a commutator but actually isn't one.
    class FakeCommutator < Commutator
      def initialize(algorithm)
        raise ArgumentError unless algorithm.is_a?(Algorithm)

        @algorithm = algorithm
      end

      attr_reader :algorithm

      def eql?(other)
        self.class.equal?(other.class) && @algorithm == other.algorithm
      end

      alias == eql?

      def hash
        @hash ||= [self.class, @algorithm].hash
      end

      def inverse
        FakeCommutator.new(@algorithm.inverse)
      end

      def to_s
        @algorithm.to_s
      end
    end

    # Pure commutator of the form A B A' B'.
    class PureCommutator < Commutator
      def initialize(first_part, second_part)
        raise ArgumentError unless first_part.is_a?(Algorithm)
        raise ArgumentError unless second_part.is_a?(Algorithm)

        @first_part = first_part
        @second_part = second_part
      end

      attr_reader :first_part, :second_part

      def eql?(other)
        self.class.equal?(other.class) && @first_part == other.first_part &&
          @second_part == other.second_part
      end

      alias == eql?

      def hash
        @hash ||= [self.class, @first_part, @second_part].hash
      end

      def inverse
        PureCommutator.new(second_part, first_part)
      end

      def to_s
        "[#{@first_part}, #{@second_part}]"
      end

      def algorithm
        first_part + second_part + first_part.inverse + second_part.inverse
      end
    end

    # Setup commutator of the form A B A'.
    class SetupCommutator < Commutator
      def initialize(setup, inner_commutator)
        raise ArgumentError, 'Setup move has to be an algorithm.' unless setup.is_a?(Algorithm)
        unless inner_commutator.is_a?(Commutator)
          raise ArgumentError, 'Inner commutator has to be a commutator.'
        end

        @setup = setup
        @inner_commutator = inner_commutator
      end

      attr_reader :setup, :inner_commutator

      def eql?(other)
        self.class.equal?(other.class) && @setup == other.setup &&
          @inner_commutator == other.inner_commutator
      end

      alias == eql?

      def hash
        @hash ||= [self.class, @setup, @inner_commutator].hash
      end

      def inverse
        SetupCommutator.new(setup, @inner_commutator.inverse)
      end

      def to_s
        "[#{@setup} : #{@inner_commutator}]"
      end

      def algorithm
        setup + inner_commutator.algorithm + setup.inverse
      end
    end
  end
end
