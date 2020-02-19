# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/utils/array_helper'

module CubeTrainer
  # A color scheme that assigns a color to each face.
  class ColorScheme
    include Core::CubeConstants
    include Utils::ArrayHelper

    RESERVED_COLORS = %i[transparent unknown oriented].freeze

    # Corner matcher that finds a corner that has one arbitrary
    # face symbol and two given face symbol.
    class CornerMatcher
      def initialize(face_symbol_matchers)
        unless face_symbol_matchers.count(&:nil?) == 1
          raise ArgumentError, 'Exactly one nil allowed in face symbol matchers.'
        end

        @face_symbol_matchers = face_symbol_matchers
      end

      def matches?(corner)
        corner.face_symbols.zip(@face_symbol_matchers).all? do |face_symbol, face_symbol_matcher|
          face_symbol_matcher.nil? || face_symbol == face_symbol_matcher
        end
      end

      def wildcard_index
        @face_symbol_matchers.index(nil)
      end
    end

    def check_face_symbols_to_colors(face_symbols_to_colors)
      raise ArgumentError unless face_symbols_to_colors.keys.sort == FACE_SYMBOLS.sort

      face_symbols_to_colors.values.each do |c|
        raise TypeError unless c.is_a?(Symbol)

        if RESERVED_COLORS.include?(c)
          raise ArgumentError,
                "Color #{c} cannot be part of the color scheme because it is a reserved color."
        end
      end
      raise ArgumentError unless face_symbols_to_colors.values.all? { |c| c.is_a?(Symbol) }
    end

    def initialize(face_symbols_to_colors)
      check_face_symbols_to_colors(face_symbols_to_colors)

      num_uniq_colors = face_symbols_to_colors.values.uniq.length
      unless num_uniq_colors == FACE_SYMBOLS.length
        raise ArgumentError, "Got #{num_uniq_colors} unique colors " \
                             "#{face_symbols_to_colors.values.uniq}, " \
                             "but needed #{FACE_SYMBOLS.length}."
      end

      @face_symbols_to_colors = face_symbols_to_colors
      @colors_to_face_symbols = face_symbols_to_colors.invert
    end

    def color(face_symbol)
      @face_symbols_to_colors[face_symbol]
    end

    def opposite_color(color)
      color(opposite_face_symbol(face_symbol(color)))
    end

    def part_for_colors(part_type, colors)
      raise ArgumentError unless part_type.is_a?(Class)

      part_type.for_face_symbols(colors.map { |c| face_symbol(c) })
    end

    def face_symbol(color)
      @colors_to_face_symbols[color]
    end

    def colors
      @face_symbols_to_colors.values
    end

    def turned(top_color, front_color)
      raise ArgumentError if top_color == front_color
      raise ArgumentError if opposite_color(top_color) == front_color
      raise ArgumentError unless colors.include?(top_color)
      raise ArgumentError unless colors.include?(front_color)

      # Note: The reason that this is so complicated is that we want it to still work if the
      # chirality corner gets exchanged.

      # Do the obvious and handle opposites of the top and front color so we have no
      # assumptions that the chirality corner contains U and F.
      turned_face_symbols_to_colors =
        obvious_turned_face_symbols_to_colors(top_color, front_color)

      # Now find the corner that gets mapped to the chirality corner. We know
      # two of its colors and the position of the missing color.
      chirality_corner_source, unknown_index =
        chirality_corner_source_and_unknown_index(turned_face_symbols_to_colors)

      add_missing_mappings(turned_face_symbols_to_colors, chirality_corner_source, unknown_index)

      ColorScheme.new(turned_face_symbols_to_colors)
    end

    WCA = new(
      U: :white,
      F: :green,
      R: :red,
      L: :orange,
      B: :blue,
      D: :yellow
    )

    def solved_cube_state(cube_size)
      stickers = ordered_colors.map do |c|
        (0...cube_size).collect { [c] * cube_size }
      end
      Core::CubeState.from_stickers(cube_size, stickers)
    end

    # Colors in the order of the face symbols.
    def ordered_colors
      FACE_SYMBOLS.map { |s| color(s) }
    end

    def solved_skewb_state
      Core::SkewbState.for_solved_colors(@face_symbols_to_colors.dup)
    end

    private

    def chirality_corner_source_and_unknown_index(obvious_turned_face_symbols_to_colors)
      corner_matcher =
        CornerMatcher.new(CHIRALITY_FACE_SYMBOLS.map do |s|
                            # This will return nil for exactly one face that we don't know yet.
                            @colors_to_face_symbols[obvious_turned_face_symbols_to_colors[s]]
                          end)

      # There should be exactly one corner that gets mapped to the chirality corner.
      chirality_corner_source = find_only(Core::Corner::ELEMENTS) do |corner|
        corner_matcher.matches?(corner)
      end
      [chirality_corner_source, corner_matcher.wildcard_index]
    end

    def add_missing_mappings(turned_face_symbols_to_colors, chirality_corner_source, unknown_index)
      missing_face_symbol = CHIRALITY_FACE_SYMBOLS[unknown_index]
      missing_face_symbol_source =
        chirality_corner_source.face_symbols[unknown_index]
      turned_face_symbols_to_colors[missing_face_symbol] = color(missing_face_symbol_source)
      turned_face_symbols_to_colors[opposite_face_symbol(missing_face_symbol)] =
        color(opposite_face_symbol(missing_face_symbol_source))
    end

    def obvious_turned_face_symbols_to_colors(top_color, front_color)
      result = { U: top_color, F: front_color }
      opposites = result.map do |face_symbol, color|
        [opposite_face_symbol(face_symbol), opposite_color(color)]
      end.to_h
      result.merge!(opposites)
    end

    BERNHARD = WCA.turned(:yellow, :red)
  end
end
