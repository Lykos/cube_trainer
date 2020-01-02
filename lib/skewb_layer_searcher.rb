require 'move'
require 'parser'

module CubeTrainer

  # Searches all possible Skewb layers.
  class SkewbLayerSearcher

    EXAMPLE_LAYER_COLOR = :white

    class SkewbLayer
      
      def initialize(layer_solution, face)
        @layer_solutions = [layer_solution]
        @face = face
      end
      
      attr_reader :layer_solutions, :face

      def layer_solution
        layer_solutions.first
      end

      def solution_length
        layer_solution.length
      end

      # Adds an alternative solution if it is equally good as the existing ones.
      # Worse solutions are ignored.
      def maybe_add_alternative_solution(layer_solution)
        case layer_solution.length <=> solution_length
        when -1 then raise ArgumentError
        when 0 then @layer_solutions.push(layer_solution)
        end
      end
      
    end

    def calculate
      state = SkewbState.solved
      candidates = [Algorithm.empty]
      layers = []
      loop do
        candidate = candidates.pop
        candidate.apply_temporarily_to(state) do
          # Is there an existing equivalent layer that we already looked at?
          has_equivalent_layer = false

          # Is there an existing equivalent layer that we already looked at with a strictly shorter solution.
          has_equivalent_shorter_layer = false

          # Find out whether there are any layers that are equivalent without rotations.
          # In those cases, we add this as an alternative solution.
          layers.each do |l|
            l.layer_solution.apply_temporarily_to(state) do
              if state.layer_solved?(EXAMPLE_LAYER_COLOR)
                l.maybe_add_alternative_solution(candidate.inverse)
                has_equivalent_layer = true
                has_equivalent_shorter_layer ||= l.solution_length < candidate.length
              end
            end
          end

          # Find out whether there are any layers that are equivalent with rotations.
          # In those cases, we don't add this as an alternative solution because there will be another one that's equivalent modulo rotations.
          candidate_face = state.center_face(EXAMPLE_LAYER_COLOR)
          layers.each do |l|
            face_to_face_rotation = candidate_face.rotation_to(l.face)
            around_face_rotations = [Algorithm.empty] + CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Algorithm.new([Rotation.new(l.face.chirality_canonicalize, d)]) }
            around_face_rotations.each do |around_face_rotation|
              rotation = face_to_face_rotation + around_face_rotation
              rotation.apply_temporarily_to(state) do
                if state.layer_solved?(EXAMPLE_LAYER_COLOR)
                  has_equivalent_layer = true
                  has_equivalent_shorter_layer ||= l.solution_length < candidate.length
                end
              end
            end
          end

          # If there were no equivalent layers in any way, this is a new type of layer.
          unless has_equivalent_layer
            layers.push(SkewbLayer.new(candidate.inverse, candidate_face))
          end

          unless has_equivalent_shorter_layer
            SkewbMove::ALL.each do |m|
              candidates.push(candidate + Algorithm.new([m]))
            end
          end
        end
      end
      layers
    end
    
  end

end
