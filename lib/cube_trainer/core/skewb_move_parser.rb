# frozen_string_literal: true

require 'cube_trainer/core/abstract_direction'
require 'cube_trainer/core/abstract_move_parser'
require 'cube_trainer/core/move_type_creator'
require 'cube_trainer/core/rotation'
require 'cube_trainer/core/skewb_move'

module CubeTrainer
  module Core
    # Parser for Skewb moves.
    class SkewbMoveParser < AbstractMoveParser
      MOVE_TYPE_CREATORS = [
        MoveTypeCreator.new(%i[axis_face cube_direction], Rotation),
        MoveTypeCreator.new(%i[axis_corner skewb_direction], SkewbMove)
      ].freeze

      def initialize(moved_corners)
        @moved_corners = moved_corners
      end

      FIXED_CORNER_INSTANCE = SkewbMoveParser.new(FixedCornerSkewbMove::MOVED_CORNERS)
      SARAHS_INSTANCE = SkewbMoveParser.new(SarahsSkewbMove::MOVED_CORNERS)

      def regexp
        @regexp ||=
          begin
            skewb_direction_names =
              AbstractDirection::POSSIBLE_SKEWB_DIRECTION_NAMES.flatten
            move_part = "(?:(?<skewb_move>[#{@moved_corners.keys.join}])" \
                        "(?<skewb_direction>[#{skewb_direction_names.join}]?))"
            rotation_direction_names =
              AbstractDirection::POSSIBLE_DIRECTION_NAMES.flatten
            rotation_direction_names.sort_by! { |e| -e.length }
            rotation_part = "(?:(?<axis_name>[#{AbstractMove::AXES.join}])" \
                            "(?<cube_direction>#{rotation_direction_names.join('|')}))"
            Regexp.new("#{move_part}|#{rotation_part}")
          end
      end

      def move_type_creators
        MOVE_TYPE_CREATORS
      end

      def parse_skewb_direction(direction_string)
        if AbstractDirection::POSSIBLE_DIRECTION_NAMES[0].include?(direction_string)
          SkewbDirection::FORWARD
        elsif AbstractDirection::POSSIBLE_DIRECTION_NAMES[-1].include?(direction_string)
          SkewbDirection::BACKWARD
        else
          raise ArgumentError
        end
      end

      def parse_part_key(name)
        name.sub('name', 'face').sub('skewb_move', 'axis_corner')
      end

      def parse_move_part(name, value)
        case name
        when 'axis_name' then CubeMoveParser::INSTANCE.parse_axis_face(value)
        when 'cube_direction' then CubeMoveParser::INSTANCE.parse_direction(value)
        when 'skewb_move' then @moved_corners[value]
        when 'skewb_direction' then parse_skewb_direction(value)
        else raise
        end
      end
    end
  end
end
