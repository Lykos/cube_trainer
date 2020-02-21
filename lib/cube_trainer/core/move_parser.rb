# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/move'

module CubeTrainer
  module Core
    # Class for parsing one move type
    class MoveTypeCreator
      def initialize(capture_keys, move_class)
        raise TypeError unless move_class.is_a?(Class)
        raise TypeError unless capture_keys.all? { |k| k.is_a?(Symbol) }

        @capture_keys = capture_keys.freeze
        @move_class = move_class
      end

      def applies_to?(parsed_parts)
        parsed_parts.keys.sort == @capture_keys.sort
      end

      def create(parsed_parts)
        raise ArgumentError unless applies_to?(parsed_parts)

        fields = @capture_keys.map { |name| parsed_parts[name] }
        @move_class.new(*fields)
      end
    end

    # Base class for move parsers.
    class AbstractMoveParser
      def regexp
        raise NotImplementedError
      end

      def parse_part_key(_name)
        raise NotImplementedError
      end

      def parse_move_part(_name, _string)
        raise NotImplementedError
      end

      def move_type_creators
        raise NotImplementedError
      end

      def parse_named_captures(match)
        present_named_captures = match.named_captures.reject { |_n, v| v.nil? }
        present_named_captures.map do |name, string|
          key = parse_part_key(name).to_sym
          value = parse_move_part(name, string)
          [key, value]
        end.to_h
      end

      def parse_move(move_string)
        match = move_string.match(regexp)
        if !match || !match.pre_match.empty? || !match.post_match.empty?
          raise ArgumentError("Invalid move #{move_string}.")
        end

        parsed_parts = parse_named_captures(match)
        move_type_creators.each do |parser|
          return parser.create(parsed_parts) if parser.applies_to?(parsed_parts)
        end
        raise "No move type creator applies to #{parsed_parts}"
      end
    end

    # Parser for cube moves.
    class CubeMoveParser < AbstractMoveParser
      REGEXP =
        begin
                        axes_part = "(?<axis_name>[#{Move::AXES.join}])"
                        face_names = CubeConstants::FACE_NAMES.join
                        fat_move_part =
                          "(?<width>\\d*)(?<fat_face_name>[#{face_names}])w"
                        normal_move_part = "(?<face_name>[#{face_names}])"
                        downcased_face_names = face_names.downcase
                        maybe_fat_maybe_slice_move_part =
                          "(?<maybe_fat_face_maybe_slice_name>[#{downcased_face_names}])"
                        slice_move_part =
                          "(?<slice_index>\\d+)(?<slice_name>[#{downcased_face_names}])"
                        mslice_move_part = "(?<mslice_name>[#{Move::SLICE_FACES.keys.join}])"
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
        Face::ELEMENTS[Move::AXES.index(axis_face_string)]
      end

      def parse_mslice_face(mslice_name)
        Move::SLICE_FACES[mslice_name]
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
            rotation_part = "(?:(?<axis_name>[#{Move::AXES.join}])" \
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
