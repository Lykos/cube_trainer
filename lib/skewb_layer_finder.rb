require 'coordinate'
require 'skewb_state'
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
    def initialize(colors)
      raise ArgumentError if colors.empty?
      raise ArgumentError unless colors.all? { |c| COLORS.include?(c) }
      @colors = colors
    end
    
    def extract_algorithms
      algs = {}
      @colors.each { |c| algs[c] = [Algorithm.empty] }
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
      @length = if internal_solution_sets.empty? then nil else internal_solution_sets.first.length end
      raise ArgumentError unless internal_solution_sets.all? { |s| s.length == @length }
      @internal_solution_sets = internal_solution_sets
    end

    attr_reader :length

    def extract_algorithms
      algs = {}
      @internal_solution_sets.each do |s|
        algs.update(s.extract_algorithms) do |k, v0, v1|
          (v0 + v1).sort_by { |a| a.to_s }
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
      algs.each do |k, v|
        v.collect! { |s| Algorithm.new([@extra_move]) + s }
      end
      algs
    end
  end

  NO_SOLUTIONS = UnionSolutionSet.new([])

  class SkewbLayerFinder
    def self.layer_score(skewb_state)
      Face::ELEMENTS.collect { |f| layer_score_on_face(skewb_state, f) }.max
    end

    MATCHING_CORNERS_HASH =
      begin
        hash = {}
        SkewbState::MATCHING_CORNERS.each do |a, b|
          hash[a.sort] = b
          hash[b.sort] = a
        end
        {}
      end

    def self.mismatch_on_outside(skewb_state, coordinates)
      raise ArgumentError unless coordinates.length == 2
      raise ArgumentError unless coordinates.all? { |c| c.is_a?(SkewbCoordinate) }
      friends = MATCHING_CORNERS_HASH[coordinates.sort]
      return false unless friends
      skewb_state[friends[0]] != skewb_state[friends[1]]
    end

    def self.layer_score_on_face(skewb_state, face)
      face_color = skewb_state[SkewbCoordinate.center(face)]
      matching_coordinates = SkewbCoordinate.corners_on_face(face).select do |c|
        skewb_state[c] == face_color
      end
      naive_score = matching_coordinates.length
      has_mismatch = matching_coordinates.combination(2).all? do |cs|
        SkewbLayerFinder.mismatch_on_outside(skewb_state, cs)
      end
      if has_mismatch then naive_score - naive_score / 2 else naive_score end
    end

    def self.score_after_move(skewb_state, move)
      move.apply_to(skewb_state)
      score = layer_score(skewb_state)
      move.invert.apply_to(skewb_state)
      score
    end

    def find_layer(skewb_state, limit, color_restrictions=COLORS)
      raise ArgumentError unless limit.is_a?(Integer) && limit >= 0
      solved_layers = skewb_state.solved_layers & color_restrictions
      if !solved_layers.empty?
        raise unless SkewbLayerFinder.layer_score(skewb_state) == 4
        return AlreadySolvedSolutionSet.new(solved_layers)
      end
      if limit == 0
        return NO_SOLUTIONS
      end
      moves = SkewbMove::ALL.dup.collect do |m|
        [m, SkewbLayerFinder.score_after_move(skewb_state, m)]
      end.select do |m, score|
        score + limit >= 4
      end.sort_by do |m, score|
        -score
      end.collect { |m, score| m }
      best_solutions = NO_SOLUTIONS
      inner_limit = limit - 1
      moves.each do |m|
        m.apply_to(skewb_state)
        # Note that limit is updated s.t. this solution helps us.
        solutions = find_layer(skewb_state, inner_limit, color_restrictions)
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
