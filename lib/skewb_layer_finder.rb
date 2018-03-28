require 'coordinate'
require 'move'

module CubeTrainer

  class SolutionSet
    # Shorter solutions should be treated as better. Unsolved is equivalent to infinity length.
    def strictly_better_than?(other)
      if !solved? && !other.solved? then
        return false
      elsif !solved?
        return false
      elsif !other.solved?
        return true
      end
      length < other.length
    end

    def solved?
      !length.nil?
    end
  end

  class AlreadySolvedSolutionSet < SolutionSet
    def extract_algorithms
      [Algorithm.empty]
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
      @length = if internal_solution_sets.empty? then nil else internal_solution_sets.first.length end
      raise ArgumentError unless internal_solution_sets.all? { |s| s.length == @length }
      @internal_solution_sets = internal_solution_sets
    end

    attr_reader :length

    def extract_algorithms
      @internal_solution_sets.collect_concat { |s| s.extract_algorithms }
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
      @internal_solution_set.extract_algorithms.collect { |s| Algorithm.new([@extra_move]) + s }
    end
  end

  NO_SOLUTIONS = UnionSolutionSet.new([])
  ALREADY_SOLVED_SOLUTIONS = AlreadySolvedSolutionSet.new

  class SkewbLayerFinder
    def layer_score(skewb_state)
      Face::ELEMENTS.collect { |f| layer_score_on_face(skewb_state, f) }.max
    end

    def random_sequence(n)
      Algorithm.new((0...n).collect { SkewbMove::ALL.sample })
    end

    def layer_score_on_face(skewb_state, face)
      face_color = skewb_state[SkewbCoordinate.center(face)]
      skewb_state.sticker_array(face)[1..-1].count { |c| c == face_color }
    end

    def find_layer(skewb_state, limit)
      raise ArgumentError unless limit.is_a?(Integer) && limit >= 0
      if skewb_state.any_layer_solved?
        return ALREADY_SOLVED_SOLUTIONS
      end
      if limit == 0
        return NO_SOLUTIONS
      end
      moves = SkewbMove::ALL.dup.sort_by do |m|
        m.apply_to(skewb_state)
        score = layer_score(skewb_state)
        m.invert.apply_to(skewb_state)
        score
      end.reverse
      best_solutions = NO_SOLUTIONS
      inner_limit = limit - 1
      moves.each do |m|
        m.apply_to(skewb_state)
        # Note that limit is updated s.t. this solution helps us.
        solutions = find_layer(skewb_state, inner_limit)
        m.invert.apply_to(skewb_state)
        if solutions.solved? then
          adjusted_solutions = FirstMovePlusSolutions.new(m, solutions)
          if adjusted_solutions.strictly_better_than?(best_solutions)
            best_solutions = adjusted_solutions
            inner_limit = solutions.length
          else
            best_solutions = UnionSolutionSet.new([best_solutions, adjusted_solutions])
          end
        end
      end
      best_solutions
    end
  end
  
end
