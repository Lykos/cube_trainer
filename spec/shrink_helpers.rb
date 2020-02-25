# frozen_string_literal: true

require 'rantly/shrinks'

module CubeTrainer
  module Core
    class Algorithm
      def shrink
        a = Algorithm.new(@moves[0...position] + @moves[position + 1..-1])
        @position = position - 1
        a
      end

      def position
        @position ||= length - 1
      end

      def retry?
        position >= 0
      end

      def shrinkable?
        !empty?
      end
    end
  end
end
