# frozen_string_literal: true

module TwistyPuzzles
  
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
end
