require 'cube_trainer/cube_print_helper'
require 'cube_trainer/cube'
require 'cube_trainer/cube_constants'
require 'cube_trainer/coordinate'
require 'cube_trainer/color_scheme'

module CubeTrainer

  class SkewbLayerFingerprinter

    include CubePrintHelper
    include CubeConstants

    # Describes how layer corners are situated in the two given corner positions
    # The boolean describes that the corners are adjacent/opposite in the layer.
    ALL_CORNER_PAIR_TYPES = [
      :both_missing,
      :one_oriented_one_missing,
      :one_twisted_one_missing,
      :both_oriented_and_adjacent,
      :both_oriented_and_opposite,
      :one_oriented_one_twisted_and_adjacent,
      :one_oriented_one_twisted_and_opposite,
      :both_twisted_same_way_and_adjacent,
      :both_twisted_same_way_and_opposite,
      :both_twisted_opposite_way_and_adjacent,
      :both_twisted_opposite_way_and_opposite,
    ]
    
    def initialize(face, color_scheme)
      raise ArgumentError unless face.is_a?(Face)
      raise ArgumentError unless color_scheme.is_a?(ColorScheme)
      @face = face
      @color_scheme = color_scheme
    end

    def group_corner_pairs_by_num_common_faces(corner_pairs)
      corner_pairs.group_by { |a, b| a.common_faces(b) }.values
    end

    def corner_pair_type(skewb_state, corner_pair, layer_color)
      raise ArgumentError unless corner_pair.length == 2
      actual_colors_of_corner_pair = corner_pair.map do |corner|
        corner.rotations.map do |c|
          skewb_state[SkewbCoordinate.for_corner(c)]
        end
      end
      num_present = actual_colors_of_corner_pair.count do |colors|
        colors.include?(layer_color)
      end
      num_oriented = actual_colors_of_corner_pair.count do |colors|
        colors.first == layer_color
      end
      # Finish cases with missing corners.
      case num_present
      when 0 then return :both_missing
      when 1
        case num_oriented
        when 0 then return :one_twisted_one_missing
        when 1 then return :one_oriented_one_missing
        else raise
        end
      when 2
        # Continue the method execution.
      else
        raise
      end
      num_common_colors = (actual_colors_of_corner_pair[0] & actual_colors_of_corner_pair[1]).length
      # Now cases with 2 existing corners are remaining and we need to figure out whether
      # they are adjacent.
      is_adjacent = case num_common_colors
                    when 1 then false
                    when 2 then true
                    else raise
                    end
      basic_type = case num_oriented
                   when 2 then :both_oriented
                   when 1 then :one_oriented_one_twisted
                   when 0
                     index_of_layer_color = actual_colors_of_corner_pair.map { |colors| colors.index(layer_color) }
                     raise unless index_of_layer_color.all? { |i| [1, 2].include?(i) }
                     if index_of_layer_color[0] == index_of_layer_color[1]
                       :both_twisted_same_way
                     else
                       :both_twisted_opposite_way
                     end
                   else raise
                   end
      (basic_type.to_s + '_and_' + (is_adjacent ? 'adjacent' : 'opposite')).to_sym
    end

    MAX_CORNER_PAIRS_PER_TYPE = 8
    MAX_CORNER_PAIR_TYPES_FINGERPRINT = (MAX_CORNER_PAIRS_PER_TYPE + 1) ** ALL_CORNER_PAIR_TYPES.length

    def corner_pair_group_fingerprint(skewb_state, corner_pairs, layer_color)
      corner_pair_types = corner_pairs.map { |p| corner_pair_type(skewb_state, p, layer_color) }
      raise ArgumentError unless (corner_pair_types - ALL_CORNER_PAIR_TYPES).empty?
      counts = ALL_CORNER_PAIR_TYPES.map { |t| corner_pair_types.count(t) }
      combine_fingerprints(counts, MAX_CORNER_PAIRS_PER_TYPE)
    end

    # Returns a number that doesn't change from rotations around `face` or mirroring.
    # It tries to be different for different types of layers, but it's not perfect yet, so some
    # layers will be mapped to the same number.
    def fingerprint(skewb_state)
      layer_color = skewb_state[SkewbCoordinate.for_center(@face)]
      layer_face_symbol = @color_scheme.face_symbol(layer_color)
      layer_corners = Corner::ELEMENTS.select { |c| c.face_symbols.first == layer_face_symbol }
      opposite_layer_face_symbol = opposite_face_symbol(layer_face_symbol)
      opposite_corners = Corner::ELEMENTS.select { |c| c.face_symbols.first == opposite_layer_face_symbol }
      corner_pair_groups = group_corner_pairs_by_num_common_faces(layer_corners.combination(2)) +
                           group_corner_pairs_by_num_common_faces(opposite_corners.combination(2)) +
                           group_corner_pairs_by_num_common_faces(layer_corners.product(opposite_corners))
      corner_pair_group_fingerprints = corner_pair_groups.map do |g|
        corner_pair_group_fingerprint(skewb_state, g, layer_color)
      end
      combine_fingerprints(corner_pair_group_fingerprints, MAX_CORNER_PAIR_TYPES_FINGERPRINT)
    end

    def combine_fingerprints(sub_fingerprints, max_per_fingerprint)
      raise ArgumentError unless max_per_fingerprint.is_a?(Integer)
      sub_fingerprints.inject(0) do |sum, fingerprint|
        raise ArgumentError unless fingerprint.is_a?(Integer)
        unless fingerprint <= max_per_fingerprint
          raise ArgumentError, "Got sub fingerprint #{fingerprint}, but max is #{max_per_fingerprint}."
        end
        sum * (max_per_fingerprint + 1) + fingerprint
      end
    end
  end

end
