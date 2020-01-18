require 'cube'

module ColorScheme

  class ColorScheme

    def initialize(opposite_color_pairs, chirality_colors)
      raise ArgumentError unless opposite_color_pairs.length == 2
      raise ArgumentError unless opposite_color_pairs.length == 2
      @opposites = (opposite_color_pairs + opposite_color_pairs.map { |e| e.reverse }).to_hash
      @chirality_colors = chirality_colors
    end

    attr_reader :chirality_colors

    def opposite_color(color)
      @opposites[color]
    end

  end
  
end
