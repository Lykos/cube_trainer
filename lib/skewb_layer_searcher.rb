require 'move'
require 'parser'
require 'skewb_layer_finder'
require 'cube_print_helper'
require 'set'

module CubeTrainer

  # Searches all possible Skewb layers.
  class SkewbLayerSearcher

    include CubePrintHelper

    EXAMPLE_LAYER_COLOR = :white

    # Represents a possible Skewb layer with a solution and the face where the solved layer initially lies.
    class SkewbLayerSolution

      # Face is the initial face where the solved center is.
      def initialize(move, sub_solution, face)
        raise ArgumentError unless move.nil? || move.is_a?(Move)
        raise ArgumentError unless sub_solution.nil? || sub_solution.is_a?(SkewbLayerSolution)
        raise ArgumentError unless move.nil? == sub_solution.nil?
        raise ArgumentError unless face.is_a?(Face)
        @move = move
        @sub_solution = sub_solution
        @alternative_solutions = Set[]
        @face = face
      end

      alias == eql?

      def eql?(other)
        self.class.equal?(other.class) && @move == other.move && @sub_solution == other.sub_solution
      end
      
      def hash
        [@move, @sub_solution].hash
      end

      attr_reader :move, :sub_solution, :face

      def layer_solution
        @layer_solution ||= begin
                              if move.nil?
                                Algorithm.empty
                              else
                                @sub_solution.layer_solution + Algorithm.new([@move])
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

      def derived_layer_solution(move, face)
        SkewbLayerSolution.new(move, self, face)
      end

      def extract_algorithms
        [layer_solution] + @alternative_solutions.map { |s| s.layer_solution }
      end
      
    end

    class SkewbLayerCandidate
      def initialize(move, sub_solution)
        raise ArgumentError unless move.is_a?(Move)
        raise ArgumentError unless sub_solution.is_a?(SkewbLayerSolution)
        @move = move
        @sub_solution = sub_solution
      end

      attr_reader :move, :sub_solution

      def candidate_solution(face)
        SkewbLayerSolution.new(@move, @sub_solution, face)
      end

      def layer_solution
        @sub_solution.layer_solution + Algorithm.new([@move])
      end

      def to_s
        layer_solution.to_s
      end
    end

    def initialize(max_length)
      @max_length = max_length
      @layer_solutions = [SkewbLayerSolution.new(nil, nil, Face.for_color(EXAMPLE_LAYER_COLOR))]
      @good_layer_solutions = []
      @state = SkewbState.solved
      @candidates = derived_layer_candidates(@layer_solutions.first)
      @finder = SkewbLayerFinder.new([EXAMPLE_LAYER_COLOR])
    end

    attr_reader :good_layer_solutions

    def derived_layer_candidates(layer_solution)
      SarahsSkewbMove::ALL.collect_concat do |m|
        # Ignore possible moves along the same axis as the last move.
        if layer_solution.move && layer_solution.move.move == m.move
          []
        else
          [SkewbLayerCandidate.new(m, layer_solution)]
        end
      end
    end

    # Find out whether there are any layers that are equivalent without rotations.
    # In those cases, we add this as an alternative solution.
    def check_equivalent_solution(candidate_solution)
      has_equivalent_solution = false
      @layer_solutions.each do |l|
        l.layer_solution.apply_temporarily_to(@state) do
          if @state.layer_solved?(EXAMPLE_LAYER_COLOR)
            l.maybe_add_alternative_solution(candidate_solution)
            has_equivalent_solution = true
          end
        end
      end
      has_equivalent_solution
    end

    # Find out whether there are any layers that are equivalent with rotations.
    # In those cases, we don't add this as an alternative solution because there will be another one that's equivalent modulo rotations.
    def check_equivalent_modified_solution(candidate_solution)
      has_equivalent_solution = false
      @layer_solutions.each do |l|
        face_to_face_rotation = candidate_solution.face.rotation_to(l.face)
        around_face_rotations = [Algorithm.empty] + CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Algorithm.new([Rotation.new(l.face.chirality_canonicalize, d)]) }
        around_face_rotations.each do |around_face_rotation|
          rotation = face_to_face_rotation + around_face_rotation
          rotation.apply_temporarily_to(@state) do
            l.layer_solution.apply_temporarily_to(@state) do
              if @state.layer_solved?(EXAMPLE_LAYER_COLOR)
                has_equivalent_solution = true
              end
            end
            @state.mirror!
            l.layer_solution.apply_temporarily_to(@state) do
              if @state.layer_solved?(EXAMPLE_LAYER_COLOR)
                has_equivalent_solution = true
              end
            end
            @state.mirror!
          end
        end
      end
      has_equivalent_solution
    end
    
    def self.calculate(max_length=nil)
      searcher = new(max_length)
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

    def state_is_good?(candidate_solution)
      @finder.state_score(@state) >= 2 || candidate_solution.solution_length <= 3
    end

    def calculate
      until candidates_empty?
        puts "Candidates: #{@candidates.length} Layers: #{@layer_solutions.length} Good layers: #{@good_layer_solutions.length}"
        candidate = pop_candidate
        puts "Candidate: #{candidate}"        
        candidate.layer_solution.inverse.apply_temporarily_to(@state) do
          # Is there an existing equivalent layer that we already looked at?
          has_equivalent_layer = false

          candidate_face = @state.center_face(EXAMPLE_LAYER_COLOR)
          candidate_solution = candidate.candidate_solution(candidate_face)
          has_equivalent_layer ||= check_equivalent_solution(candidate_solution)
          has_equivalent_layer ||= check_equivalent_modified_solution(candidate_solution)
          
          unless has_equivalent_layer
            # If there were no equivalent layers in any way, this is a new type of layer.
            @layer_solutions.push(candidate_solution)
            if state_is_good?(candidate_solution)
              @good_layer_solutions.push(candidate_solution)
              puts @finder.state_score(@state)
              puts skewb_string(@state, :color)
            end
            if @max_length.nil? || candidate_solution.solution_length < @max_length
              add_new_candidates(derived_layer_candidates(candidate_solution))
            end
          end
        end
      end
    end
    
  end

end
