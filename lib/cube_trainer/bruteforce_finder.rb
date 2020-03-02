# frozen_string_literal: true

require 'cube_trainer/core/algorithm'

module CubeTrainer
  # Partial set of solutions to get from a given puzzle state to one with some desired properties.
  class SolutionSet
    # Shorter solutions should be treated as better. Unsolved is equivalent to infinity length.
    def strictly_better_than?(other)
      return false unless solved?
      return true unless other.solved?

      length < other.length
    end

    def solved?
      !length.nil?
    end
  end

  # Trivial set of solutions where nothing has to be done.
  class AlreadySolvedSolutionSet < SolutionSet
    def initialize(colors)
      raise ArgumentError if colors.empty?

      @colors = colors
    end

    def extract_algorithms
      algs = {}
      @colors.each { |c| algs[c] = [Core::Algorithm::EMPTY] }
      algs
    end

    def length
      0
    end
  end

  # Empty set of solutions that represents the case that there are no solutions.
  class NoSolutionSet < SolutionSet
    def extract_algorithms
      []
    end

    def length
      nil
    end
  end

  # Union of several solution sets.
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

  # Solution sets that starts with one move and then another set of solutions.
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
        v.map! { |s| @extra_move + s }
      end
      algs
    end
  end

  NO_SOLUTIONS = UnionSolutionSet.new([])

  # Base class for classes that search how to get from
  # a given puzzle state to a state with some desired
  # properties.
  class BruteForceFinder
    def initialize(find_all_solutions = true)
      @find_all_solutions = find_all_solutions
    end

    def state_score(_state)
      raise NotImplementedError
    end

    def score_after_move(state, move)
      move.apply_temporarily_to(state) { |s| state_score(s) }
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

    def ordered_moves(state, limit)
      scored_moves =
        generate_moves(state).map! do |m|
          [m, score_after_move(state, m)]
        end
      scored_moves.select! do |_m, score|
        score + limit >= 4
      end
      scored_moves.sort_by! do |_m, score|
        -score
      end.map(&:first)
    end

    def find_solutions(state, limit)
      raise TypeError unless limit.is_a?(Integer)

      find_solutions_internal(state, limit)
    end

    private

    def already_solved_solutions(state)
      sols = solved_colors(state)
      unless sols.empty?
        raise unless state_score(state) == solution_score

        return AlreadySolvedSolutionSet.new(sols)
      end
      nil
    end

    def prepend_move(move, solutions)
      solutions.solved? ? FirstMovePlusSolutions.new(move, solutions) : solutions
    end

    def solutions_after_move(state, move, inner_limit)
      solutions = move.apply_temporarily_to(state) { |s| find_solutions_internal(s, inner_limit) }
      prepend_move(move, solutions)
    end

    def new_solutions_and_limit(solutions, old_solutions, old_limit)
      if solutions.strictly_better_than?(old_solutions)
        new_limit = new_move_limit(solutions.length - 1)
        [solutions, new_limit]
      else
        new_solutions = UnionSolutionSet.new([old_solutions, solutions])
        [new_solutions, old_limit]
      end
    end

    def find_solutions_internal(state, limit)
      raise ArgumentError if limit.negative?

      sols = already_solved_solutions(state)
      return sols if sols
      return NO_SOLUTIONS if limit.zero?

      moves = ordered_moves(state, limit)
      best_solutions = NO_SOLUTIONS
      inner_limit = limit - 1
      moves.each do |m|
        # Note that limit is updated s.t. this solution helps us.
        solutions = solutions_after_move(state, m, inner_limit)
        next unless solutions.solved?

        best_solutions, inner_limit =
          new_solutions_and_limit(solutions, best_solutions, inner_limit)
        break if inner_limit.negative?
      end
      best_solutions
    end
  end
end
