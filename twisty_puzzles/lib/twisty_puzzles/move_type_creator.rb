# frozen_string_literal: true

module TwistyPuzzles
  
    # Class for creating one move type from its parts.
    # Helper class for parsing logic.
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
end
