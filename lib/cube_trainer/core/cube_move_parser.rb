# frozen_string_literal: true

require 'cube_trainer/core/abstract_direction'
require 'cube_trainer/core/abstract_move_parser'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/cube_move'
require 'cube_trainer/core/move_type_creator'
require 'cube_trainer/core/rotation'
require 'cube_trainer/core/skewb_move'

module CubeTrainer
  module Core
    # Parser for cube moves.
    class CubeMoveParser < AbstractMoveParser
      REGEXP =
        begin
                        axes_part = "(?<axis_name>[#{AbstractMove::AXES.join}])"
                        face_names = CubeConstants::FACE_NAMES.join
                        fat_move_part =
                          "(?<width>\\d*)(?<fat_face_name>[#{face_names}])w"
                        normal_move_part = "(?<face_name>[#{face_names}])"
                        downcased_face_names = face_names.downcase
                        maybe_fat_maybe_slice_move_part =
                          "(?<maybe_fat_face_maybe_slice_name>[#{downcased_face_names}])"
                        slice_move_part =
                          "(?<slice_index>\\d+)(?<slice_name>[#{downcased_face_names}])"
                        mslice_move_part =
                          "(?<mslice_name>[#{AbstractMove::SLICE_FACES.keys.join}])"
                        move_part = "(?:#{axes_part}|" \
                                    "#{fat_move_part}|" \
                                    "#{normal_move_part}|" \
                                    "#{maybe_fat_maybe_slice_move_part}|" \
                                    "#{slice_move_part}|#{mslice_move_part})"
                        direction_names =
                          AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten
                        direction_names.sort_by! { |e| -e.length }
                        direction_part = "(?<direction>#{direction_names.join('|')})"
                        Regexp.new("#{move_part}#{direction_part}")
                      end

      MOVE_TYPE_CREATORS = [
        MoveTypeCreator.new(%i[axis_face direction], Rotation),
        MoveTypeCreator.new(%i[fat_face direction width], FatMove),
        MoveTypeCreator.new(%i[face direction], FatMove),
        MoveTypeCreator.new(%i[maybe_fat_face_maybe_slice_face direction], MaybeFatMaybeSliceMove),
        MoveTypeCreator.new(%i[slice_face direction slice_index], SliceMove),
        MoveTypeCreator.new(%i[mslice_face direction], MaybeFatMSliceMaybeInnerMSliceMove)
      ].freeze

      INSTANCE = CubeMoveParser.new
      def regexp
        REGEXP
      end

      def move_type_creators
        MOVE_TYPE_CREATORS
      end

      def parse_part_key(name)
        name.sub('_name', '_face').sub('face_face', 'face')
      end

      def parse_direction(direction_string)
        value = AbstractDirection::POSSIBLE_DIRECTION_NAMES.index do |ds|
          ds.include?(direction_string)
        end + 1
        CubeDirection.new(value)
      end

      def parse_axis_face(axis_face_string)
        Face::ELEMENTS[AbstractMove::AXES.index(axis_face_string)]
      end

      def parse_mslice_face(mslice_name)
        AbstractMove::SLICE_FACES[mslice_name]
      end

      def parse_width(width_string)
        width_string.empty? ? 2 : Integer(width_string, 10)
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def parse_move_part(name, value)
        case name
        when 'axis_name' then parse_axis_face(value)
        when 'width' then parse_width(value)
        when 'slice_index' then Integer(value, 10)
        when 'fat_face_name', 'face_name' then Face.by_name(value)
        when 'maybe_fat_face_maybe_slice_name', 'slice_name'
          Face.by_name(value.upcase)
        when 'mslice_name'
          parse_mslice_face(value)
        when 'direction' then parse_direction(value)
        else raise
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
