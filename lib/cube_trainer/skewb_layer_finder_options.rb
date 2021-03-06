# frozen_string_literal: true

require 'ostruct'
require 'cube_trainer/cube_trainer_options_parser'
require 'twisty_puzzles'

module CubeTrainer
  # Command line options for the skewb layer finder binary.
  class SkewbLayerFinderOptions
    def self.default_options
      options = OpenStruct.new
      options.color_scheme = TwistyPuzzles::ColorScheme::BERNHARD
      options
    end

    def self.parse(args)
      options = default_options

      CubeTrainerOptionsParser.new(options) do |opts|
        opts.on(
          '-x', '--restrict_colors COLORLIST',
          /[yrbgow]+/, 'Restrict colors to find a layer for.'
        ) do |colors|
          options.restrict_colors =
            colors.each_char.map do |c|
              options.color_scheme.colors.find { |o| o.to_s[0] == c }
            end
        end
      end.parse!(args)
      options
    end
  end
end
