# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Training
    # Represents the solution of a particular case (i.e. a situation on the cube).
    # There is always a best alg and there might be alternative algs.
    class CaseSolution
      def initialize(best_alg, cube_size = nil, alternative_algs = [])
        check_equivalent_algs(cube_size, best_alg, alternative_algs)

        @cube_size = cube_size
        @best_alg = best_alg
        @alternative_algs = alternative_algs
      end

      attr_reader :cube_size, :best_alg, :alternative_algs

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
        raise ArgumentError if @cube_size && other.cube_size && @cube_size != other.cube_size

        # We avoid alternative algs to avoid combinatorial explosion.
        CaseSolution.new(
          @best_alg + other.best_alg, @cube_size || other.cube_size,
          alternative_algs
        )
      end

      private

      def check_equivalent_algs(cube_size, best_alg, alternative_algs)
        return if alternative_algs.empty?

        solved = TwistyPuzzles::ColorScheme::WCA.solved_cube_state(cube_size)
        case_state = best_alg.inverse.apply_to_dupped(solved)

        alternative_algs.each do |alg|
          alg.apply_temporarily_to(case_state) do |state|
            unless state == solved
              raise ArgumentError,
                    "Alternative alg #{alg} is not equivalent to best alg #{best_alg}"
            end
          end
        end
      end
    end
  end
end
