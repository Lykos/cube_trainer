# frozen_string_literal: true

require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/move'
require 'cube_trainer/core/skewb_state'

module CubeTrainer
  class SkewbLayerImprover
    include CubePrintHelper

    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(Face)

      @state = color_scheme.solved_skewb_state
      @solved_color = color_scheme.color(face)
      @alg_transformations = Core::AlgorithmTransformation.around_face(face)
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

    FACE_SYMBOLS_ORDERED_BY_PRIORITY = %i[D U F R L B].freeze

    CORNER_COORDINATES_ORDERED_BY_PRIORITY = Corner::ELEMENTS.sort_by do |c|
      face_index = FACE_SYMBOLS_ORDERED_BY_PRIORITY.index(c.face_symbols.first)
      within_face_index = if c.face_symbols.first == :D
                            case c.piece_index % 4
                            when 0 then 3
                            when 1 then 1
                            when 2 then 2
                            when 3 then 0
                            else raise
                            end
                          else
                            3 - c.piece_index % 4
                          end
      face_index * 4 + within_face_index
    end.map { |c| SkewbCoordinate.for_corner(c) }

    # How nice a particular variation of a layer is. E.g. for adjacent solved corners, we want them in the back.
    # Higher scores are better.
    def layer_score
      CORNER_COORDINATES_ORDERED_BY_PRIORITY.inject(0) do |sum, c|
        corner_present = @state[c] == @solved_color
        2 * sum + (corner_present ? 1 : 0)
      end
    end
  end
end
