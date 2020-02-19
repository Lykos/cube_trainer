# frozen_string_literal: true

require 'cube_trainer/core/algorithm'

module CubeTrainer
  class SolutionSet
    # Shorter solutions should be treated as better. Unsolved is equivalent to infinity length.
    def strictly_better_than?(other)
      return false if !solved?
      return true if !other.solved?

      length < other.length
    end

    def solved?
      !length.nil?
    end
  end

  class AlreadySolvedSolutionSet < SolutionSet
    def initialize(colors)
      raise ArgumentError if colors.empty?

      @colors = colors
    end

    def extract_algorithms
      algs = {}
      @colors.each { |c| algs[c] = [Core::Algorithm.empty] }
      algs
    end

    def length
      0
    end
  end

  class NoSolutionSet < SolutionSet
    def extract_algorithms
      []
    end

    def length
      nil
    end
  end

  class UnionSolutionSet < SolutionSet
    def initialize(internal_solution_sets)
      @length = internal_solution_sets.empty? ? nil : internal_solution_sets.first.length
      raise ArgumentError unless internal_solution_sets.all? { |s| s.length == @length }

      @internal_solution_sets = internal_solution_sets
    end

    attr_reader :length

    def extract_algorithms
      algs = {}
      @internal_solution_sets.each do |s|
        algs.update(s.extract_algorithms) do |_k, v0, v1|
          (v0 + v1).sort_by(&:to_s)
        end
      end
      algs
    end
  end

  class FirstMovePlusSolutions < SolutionSet
    def initialize(extra_move, internal_solution_set)
      @length = internal_solution_set.length + 1
      @extra_move = extra_move
      @internal_solution_set = internal_solution_set
    end

    attr_reader :length

    def extract_algorithms
      algs = @internal_solution_set.extract_algorithms
      algs.each do |_k, v|
        v.collect! { |s| @extra_move + s }
      end
      algs
    end
  end

  NO_SOLUTIONS = UnionSolutionSet.new([])

  class BruteForceFinder
    def initialize(find_all_solutions = true)
      @find_all_solutions = find_all_solutions
    end

    def state_score(_state)
      raise NotImplementedError
    end

    def score_after_move(state, move)
      move.apply_temporarily_to(state) { state_score(state) }
    end

    def done?(_state)
      raise NotImplementedError
    end

    def generate_moves(_state)
      raise NotImplementedError
    end

    # Computes the new move limit for subsequent solutions given a solution we already found.
    # Depending on whether we want to find all solutions or just one, solutions with the same number
    # of moves do or don't help. So we adjust the limit accordingly
    def new_move_limit(solutions_length)
      if @find_all_solutions
        solutions_length
      else
        solutions_length - 1
      end
    end

    def find_solutions(state, limit)
      raise ArgumentError unless limit.is_a?(Integer) && limit >= 0

      sols = solved_colors(state)
      unless sols.empty?
        raise unless state_score(state) == solution_score

        return AlreadySolvedSolutionSet.new(sols)
      end
      return NO_SOLUTIONS if limit == 0

      moves = generate_moves(state).collect do |m|
        [m, score_after_move(state, m)]
      end.select do |_m, score|
        score + limit >= 4
      end.sort_by do |_m, score|
        -score
      end.collect { |m, _score| m }
      best_solutions = NO_SOLUTIONS
      inner_limit = limit - 1
      moves.each do |m|
        solutions = m.apply_temporarily_to(state) do
          # Note that limit is updated s.t. this solution helps us.
          find_solutions(state, inner_limit)
        end
        next unless solutions.solved?

        adjusted_solutions = FirstMovePlusSolutions.new(m, solutions)
        if adjusted_solutions.strictly_better_than?(best_solutions)
          best_solutions = adjusted_solutions
          inner_limit = new_move_limit(solutions.length)
          break if inner_limit < 0
        else
          best_solutions = UnionSolutionSet.new([best_solutions, adjusted_solutions])
        end
      end
      best_solutions
    end
  end
end
