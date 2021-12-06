# frozen_string_literal: true

require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/skewb_layer_fingerprinter'
require 'set'
require 'twisty_puzzles'

module CubeTrainer
  # Searches all possible Skewb layers.
  # rubocop:disable Rails/Delegate
  class SkewbLayerSearcher
    EXAMPLE_LAYER_FACE_SYMBOL = :D
    EXAMPLE_LAYER_FACE = TwistyPuzzles::Face.for_face_symbol(EXAMPLE_LAYER_FACE_SYMBOL)
    ALGORITHM_TRANSFORMATIONS =
      TwistyPuzzles::AlgorithmTransformation.around_face_without_identity(EXAMPLE_LAYER_FACE)

    # Represents a possible Skewb layer with a solution.
    class SkewbLayerSolution
      def initialize(move, sub_solution)
        raise TypeError unless move.nil? || move.is_a?(TwistyPuzzles::SkewbMove)
        raise ArgumentError unless sub_solution.nil? || sub_solution.is_a?(SkewbLayerSolution)
        raise ArgumentError unless move.nil? == sub_solution.nil?

        @move = move
        @sub_solution = sub_solution
        @alternative_solutions = Set[]
      end

      alias == eql?

      def eql?(other)
        self.class.equal?(other.class) && @move == other.move && @sub_solution == other.sub_solution
      end

      def hash
        @hash ||= [self.class, @move, @sub_solution].hash
      end

      def to_s
        algorithm.to_s
      end

      attr_reader :move, :sub_solution

      def algorithm
        @algorithm ||=
          if move.nil?
            TwistyPuzzles::Algorithm.empty
          else
            TwistyPuzzles::Algorithm.move(@move) + @sub_solution.algorithm
          end
      end

      def compiled_algorithm
        @compiled_algorithm ||=
          if move.nil?
            TwistyPuzzles::CompiledSkewbAlgorithm::EMPTY
          else
            TwistyPuzzles::Algorithm.move(@move).compiled_for_skewb +
              @sub_solution.compiled_algorithm
          end
      end

      def algorithm_length
        algorithm.length
      end

      # Adds an alternative solution if it is equally good as the existing ones.
      # Worse solutions are ignored.
      def maybe_add_alternative_solution(layer_solution)
        raise ArgumentError unless layer_solution.is_a?(SkewbLayerSolution)

        case layer_solution.algorithm_length <=> algorithm_length
        when -1 then raise ArgumentError
        when 0 then @alternative_solutions.add(layer_solution)
        end
      end

      def extract_own_algs
        if @sub_solution
          @sub_solution.extract_algorithms.map do |alg|
            TwistyPuzzles::Algorithm.move(@move) + alg
          end
        else
          [TwistyPuzzles::Algorithm.empty]
        end
      end

      def extract_algorithms
        alternative_algs = @alternative_solutions.collect_concat(&:extract_algorithms)
        extract_own_algs + alternative_algs
      end
    end

    def initialize(color_scheme, verbose, max_length)
      raise TypeError unless color_scheme.is_a?(TwistyPuzzles::ColorScheme)
      raise TypeError unless max_length.nil? || max_length.is_a?(Integer)

      @verbose = verbose
      @max_length = max_length
      @good_layer_solutions = []
      @state = color_scheme.solved_skewb_state
      solved_solution = SkewbLayerSolution.new(nil, nil)
      example_layer_color = color_scheme.color(EXAMPLE_LAYER_FACE_SYMBOL)
      @candidates = [solved_solution]
      @finder = SkewbLayerFinder.new([example_layer_color])
      @fingerprinter = SkewbLayerFingerprinter.new(EXAMPLE_LAYER_FACE)
      @layer_solutions = {}
      @num_layer_solutions = 0
    end

    attr_reader :good_layer_solutions

    def derived_layer_solutions(layer_solution)
      TwistyPuzzles::SkewbNotation.sarah.non_zero_moves.reverse.collect_concat do |m|
        # Ignore possible moves along the same axis as the last move.
        if layer_solution.move && layer_solution.move.axis_corner == m.axis_corner
          []
        else
          [SkewbLayerSolution.new(m, layer_solution)]
        end
      end
    end

    # Find out whether there are any layers that are equivalent without rotations.
    # In those cases, we add this as an alternative solution.
    def check_equivalent_solution(candidate, state)
      layer_solution = relevant_layer_solutions(state).find { |l| solves?(l, state) }
      if layer_solution
        layer_solution.maybe_add_alternative_solution(candidate)
        puts "equivalent to #{layer_solution}" if @verbose
      end
      layer_solution
    end

    def create_transformed_states(candidate, state)
      # We go back to the original state and then apply
      # a transformed version of the inverse of the algorithm.
      candidate.compiled_algorithm.apply_temporarily_to(state) do |s|
        ALGORITHM_TRANSFORMATIONS.map do |t|
          transformed = t.transformed(candidate.compiled_algorithm).inverse
          transformed.apply_to_dupped(s)
        end
      end
    end

    def solves?(layer_solution, state)
      layer_solution.compiled_algorithm.apply_temporarily_to(state) do |s|
        s.layer_at_face_solved?(EXAMPLE_LAYER_FACE)
      end
    end

    # Find out whether there are any layers that are equivalent with rotations.
    # In those cases, we don't add this as an alternative solution because there will be
    # another one that's equivalent modulo rotations.
    def check_equivalent_modified_solution(candidate, state)
      equivalent_index = nil
      transformed_states = create_transformed_states(candidate, state)
      relevant_layer_solutions(state).each do |l|
        equivalent_index = transformed_states.find_index { |s| solves?(l, s) }
        if equivalent_index
          puts "transformed #{equivalent_index} equivalent to #{l}" if @verbose
          break
        end
      end
      !equivalent_index.nil?
    end

    def self.calculate(color_scheme, verbose, max_length = nil)
      searcher = new(color_scheme, verbose, max_length)
      searcher.calculate
      searcher.good_layer_solutions.map(&:extract_algorithms)
    end

    def pop_candidate
      @candidates.pop
    end

    def add_new_candidates(candidates)
      @candidates = candidates + @candidates
    end

    def candidates_empty?
      @candidates.empty?
    end

    def state_is_good?(candidate, state)
      @finder.state_score(state) >= 2 || candidate.algorithm_length <= 3
    end

    def relevant_layer_solutions(state)
      @layer_solutions[@fingerprinter.fingerprint(state)] ||= []
    end

    def add_layer_solution(candidate, state)
      @num_layer_solutions += 1
      relevant_layer_solutions(state).push(candidate)
    end

    def promote_candidate(candidate, state)
      add_layer_solution(candidate, state)
      @good_layer_solutions.push(candidate) if state_is_good?(candidate, state)
      return unless @max_length.nil? || candidate.algorithm_length < @max_length

      add_new_candidates(derived_layer_solutions(candidate))
    end

    def puts_report
      puts "Candidates: #{@candidates.length} Layers: #{@num_layer_solutions} " \
           "Good layers: #{@good_layer_solutions.length}"
    end

    def calculate
      until candidates_empty?
        candidate = pop_candidate
        puts_report if @verbose
        puts "Candidate: #{candidate}" if @verbose
        candidate.compiled_algorithm.inverse.apply_temporarily_to(@state) do |s|
          # Is there an existing equivalent layer that we already looked at?
          has_equivalent_layer = check_equivalent_solution(candidate, s) ||
                                 check_equivalent_modified_solution(candidate, s)

          promote_candidate(candidate, s) unless has_equivalent_layer
        end
      end
    end
  end
  # rubocop:enable Rails/Delegate
end
