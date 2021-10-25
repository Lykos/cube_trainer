# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  # Helper class that improves a Skewb layer solution to one that is equivalent
  # modulo rotations and mirrors, but better according to some canonical metric.
  class SkewbLayerImprover
    include TwistyPuzzles::CubePrintHelper
    FACE_SYMBOLS_ORDERED_BY_PRIORITY = %i[D U F R L B].freeze
    CORNERS_ORDERED_BY_PRIORITY =
      TwistyPuzzles::Corner::ELEMENTS.sort_by do |c|
        face_index = FACE_SYMBOLS_ORDERED_BY_PRIORITY.index(c.face_symbols.first)
        within_face_index =
          if c.face_symbols.first == :D
            case c.piece_index % 4
            when 0 then 3
            when 1 then 1
            when 2 then 2
            when 3 then 0
            else raise
            end
          else
            3 - (c.piece_index % 4)
          end
        (face_index * 4) + within_face_index
      end
    CORNER_COORDINATES_ORDERED_BY_PRIORITY =
      CORNERS_ORDERED_BY_PRIORITY.map { |c| TwistyPuzzles::SkewbCoordinate.for_corner(c) }

    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(TwistyPuzzles::Face)

      @state = color_scheme.solved_skewb_state
      @solved_color = color_scheme.color(face)
      @alg_transformations = TwistyPuzzles::AlgorithmTransformation.around_face(face)
    end

    def alg_variations(algorithm)
      @alg_transformations.map { |t| t.transformed(algorithm) }
    end

    def improve_layer(algorithm)
      alg_variations(algorithm).max_by do |alg|
        alg.apply_temporarily_to(@state) do
          layer_score
        end
      end
    end

    # How nice a particular variation of a layer is. E.g. for adjacent solved corners,
    # we want them in the back.
    # Higher scores are better.
    def layer_score
      CORNER_COORDINATES_ORDERED_BY_PRIORITY.reduce(0) do |sum, c|
        corner_present = @state[c] == @solved_color
        (2 * sum) + (corner_present ? 1 : 0)
      end
    end
  end
end
