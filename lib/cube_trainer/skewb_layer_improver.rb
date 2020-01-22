require 'cube_trainer/skewb_state'
require 'cube_trainer/move'
require 'cube_trainer/coordinate'
require 'cube_trainer/cube_print_helper'

module CubeTrainer

  class SkewbLayerImprover

    include CubePrintHelper

    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(Face)
      @state = color_scheme.solved_skewb_state
      @face = face
    end

    def alg_variations(algorithm)
      mirror_normal = @face.neighbors.first
      (0..3).map { |d| CubeDirection.new(d) }.product([true, false]).map do |d, m|
        alg = if d.value == 0
                algorithm
              else
                algorithm.rotate(Rotation.new(@face.chirality_canonicalize, d))
              end
        if m then alg.mirror(mirror_normal) else alg end
      end
    end

    def improve_layer(algorithm)
      alg_variations(algorithm).max_by do |alg|
        alg.apply_temporarily_to(@state) do
          layer_score
        end
      end
    end

    COLORS_ORDERED_BY_PRIORITY = [:white, :yellow, :red, :green, :blue, :orange]

    CORNER_COORDINATES_ORDERED_BY_PRIORITY = Corner::ELEMENTS.sort_by do |c|
      face_index = COLORS_ORDERED_BY_PRIORITY.index(c.colors.first)
      within_face_index = if c.colors.first == :white
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
        corner_present = @state[c] == @face.color
        2 * sum + (corner_present ? 1 : 0)
      end
    end

  end
  
end
  
