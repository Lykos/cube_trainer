require 'cube_trainer/move'
require 'cube_trainer/parser'
require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/cube'
require 'cube_trainer/color_scheme'
require 'cube_trainer/cube_print_helper'
require 'set'
require 'cube_trainer/skewb_layer_fingerprinter'

module CubeTrainer

  # Searches all possible Skewb layers.
  class SkewbLayerSearcher

    include CubePrintHelper

    class NonMoveTransformation < Struct.new(:rotation, :mirror)
      
      def apply_to(algorithm)
        algorithm = algorithm.mirror(MIRROR_NORMAL_FACE) if mirror
        algorithm.rotate_by(rotation)
      end

    end

    EXAMPLE_LAYER_FACE_SYMBOL = :D
    EXAMPLE_LAYER_FACE = Face.for_face_symbol(EXAMPLE_LAYER_FACE_SYMBOL)
    MIRROR_NORMAL_FACE = EXAMPLE_LAYER_FACE.neighbors.first
    AROUND_FACE_ROTATIONS = CubeDirection::ALL_DIRECTIONS.map { |d| Rotation.new(EXAMPLE_LAYER_FACE, d) }
    NON_MOVE_TRANSFORMATIONS = AROUND_FACE_ROTATIONS.product([true, false]).select { |r, m| r.direction.is_non_zero? || m }.map { |r, m| NonMoveTransformation.new(r, m) }

    # Represents a possible Skewb layer with a solution.
    class SkewbLayerSolution

      def initialize(move, sub_solution)
        raise ArgumentError unless move.nil? || move.is_a?(Move)
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
        layer_solution.to_s
      end

      attr_reader :move, :sub_solution

      def layer_solution
        @layer_solution ||= begin
                              if move.nil?
                                Algorithm.empty
                              else
                                Algorithm.new([@move]) + @sub_solution.layer_solution
                              end
                            end
      end

      def solution_length
        layer_solution.length
      end

      # Adds an alternative solution if it is equally good as the existing ones.
      # Worse solutions are ignored.
      def maybe_add_alternative_solution(layer_solution)
        raise ArgumentError unless layer_solution.is_a?(SkewbLayerSolution)
        case layer_solution.solution_length <=> solution_length
        when -1 then raise ArgumentError
        when 0 then @alternative_solutions.add(layer_solution)
        end
      end

      def extract_algorithms
        own_algs = if @sub_solution
                     @sub_solution.extract_algorithms.map { |alg| Algorithm.new([@move]) + alg }
                   else
                     [Algorithm.empty]
                   end
        alternative_algs = @alternative_solutions.collect_concat { |s| s.extract_algorithms }
        own_algs + alternative_algs
      end
      
    end

    def initialize(color_scheme, verbose, max_length)
      raise TypeError unless color_scheme.is_a?(ColorScheme)
      raise TypeError unless max_length.nil? || max_length.is_a?(Integer)
      @verbose = verbose
      @max_length = max_length
      @good_layer_solutions = []
      @state = color_scheme.solved_skewb_state
      solved_solution = SkewbLayerSolution.new(nil, nil)
      example_layer_color = color_scheme.color(EXAMPLE_LAYER_FACE_SYMBOL)
      @candidates = [solved_solution]
      @finder = SkewbLayerFinder.new([example_layer_color])
      @fingerprinter = SkewbLayerFingerprinter.new(EXAMPLE_LAYER_FACE, color_scheme)
      @layer_solutions = {}
      @num_layer_solutions = 0
    end

    attr_reader :good_layer_solutions

    def derived_layer_solutions(layer_solution)
      SarahsSkewbMove::ALL.reverse.collect_concat do |m|
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
    def check_equivalent_solution(candidate)
      has_equivalent_solution = false
      get_layer_solutions.each do |l|
        l.layer_solution.apply_temporarily_to(@state) do
          if @state.layer_at_face_solved?(EXAMPLE_LAYER_FACE)
            l.maybe_add_alternative_solution(candidate)
            has_equivalent_solution = true
            puts "equivalent to #{l}" if @verbose
          end
        end
      end
      has_equivalent_solution
    end

    # Find out whether there are any layers that are equivalent with rotations.
    # In those cases, we don't add this as an alternative solution because there will be another one that's equivalent modulo rotations.
    def check_equivalent_modified_solution(candidate)
      has_equivalent_solution = false
      transformed_states = NON_MOVE_TRANSFORMATIONS.collect do |t|
        # We go back to the original state and then apply a transformed version of the algorithm.
        inverse_plus_modified = candidate.layer_solution + t.apply_to(candidate.layer_solution).inverse
        inverse_plus_modified.apply_temporarily_to(@state) {
          @state.dup
        }
      end
      get_layer_solutions.each do |l|
        transformed_states.each.with_index do |s, i|
          l.layer_solution.apply_temporarily_to(s) do
            if s.layer_at_face_solved?(EXAMPLE_LAYER_FACE)
              has_equivalent_solution = true
              puts "transformed #{i} equivalent to #{l}" if @verbose
            end
          end
        end
      end
      has_equivalent_solution
    end
    
    def self.calculate(color_scheme, verbose, max_length=nil)
      searcher = new(color_scheme, verbose, max_length)
      searcher.calculate
      searcher.good_layer_solutions.map { |s| s.extract_algorithms }
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

    def state_is_good?(candidate)
      true # @finder.state_score(@state) >= 2 || candidate.solution_length <= 3
    end

    def get_layer_solutions
      @layer_solutions[@fingerprinter.fingerprint(@state)] ||= []
    end

    def add_layer_solution(candidate)
      @num_layer_solutions += 1
      get_layer_solutions.push(candidate)
    end

    def calculate
      until candidates_empty?
        candidate = pop_candidate
        puts "Candidates: #{@candidates.length} Layers: #{@num_layer_solutions} Good layers: #{@good_layer_solutions.length}" if @verbose
        puts "Candidate: #{candidate}" if @verbose
        candidate.layer_solution.inverse.apply_temporarily_to(@state) do
          # Is there an existing equivalent layer that we already looked at?
          has_equivalent_layer = false

          has_equivalent_layer ||= check_equivalent_solution(candidate)
          has_equivalent_layer ||= check_equivalent_modified_solution(candidate)
          
          unless has_equivalent_layer
            # If there were no equivalent layers in any way, this is a new type of layer.
            add_layer_solution(candidate)
            @good_layer_solutions.push(candidate) if state_is_good?(candidate)
            if @max_length.nil? || candidate.solution_length < @max_length
              add_new_candidates(derived_layer_solutions(candidate))
            end
          end
        end
      end
    end

  end

end
