# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Training
    # Represents the solution of a particular case (i.e. a situation on the cube).
    # There is always a best alg and there might be alternative algs.
    class CaseSolution
      def initialize(best_alg, alternative_algs = [])
        @best_alg = best_alg
        @alternative_algs = alternative_algs
      end

      attr_reader :best_alg, :alternative_algs

      def to_s
        case alternative_algs.length
        when 0
          @best_alg.to_s
        when 1
          "Best alg: #{@best_alg}\nAlternative alg: #{@alternative_algs[0]}"
        else
          "Best alg:\n#{@best_alg}\n\nAlternative alg:\n#{@alternative_algs.join("\n")}"
        end
      end

      def +(other)
        raise TypeError unless other.is_a?(CaseSolution)

        # We avoid alternative algs to avoid combinatorial explosion.
        CaseSolution.new(@best_alg + other.best_alg, alternative_algs)
      end

      # `solved_cube_state` should have an appropriate mask applied s.t. different valid algorithms
      # don't are equivalent except for the masked stickers.
      def check_alg_equivalence(case_description, solved_cube_state)
        return if alternative_algs.empty?

        case_state = best_alg.inverse.apply_to_dupped(solved_cube_state)
        alternative_alg_state = case_state.dup

        alternative_algs.each_with_index do |alg, index|
          alg.apply_temporarily_to(alternative_alg_state) do |state|
            unless state.equal_modulo_rotations?(solved_cube_state)
              puts "Cube looks like this wen case is set up (by applying inverse of best alg):\n#{case_state.colored_to_s}"
              puts "Cube looks like this after applying alternative alg:\n#{state.colored_to_s}"
              raise ArgumentError,
                    "Alternative alg for case \"#{case_description}\" #{alg} is not equivalent to best alg #{best_alg}."
            end
          end
        end
      end
    end
  end
end
