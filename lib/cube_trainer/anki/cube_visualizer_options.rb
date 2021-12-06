# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/cube_trainer_options_parser'
require 'ostruct'

module CubeTrainer
  module Anki
    # Command line options for the `cube_visualizer` binary.
    class CubeVisualizerOptions
      extend TwistyPuzzles

      def self.default_options
        options = OpenStruct.new
        options.color_scheme = TwistyPuzzles::ColorScheme::BERNHARD
        options.cube_size = 3
        options.algorithm = TwistyPuzzles::Algorithm.empty
        options.cache = true
        options
      end

      def self.parse(args)
        options = default_options

        CubeTrainerOptionsParser.new(options) do |opts|
          opts.on_cache
          opts.on_size
          opts.on_output('image file')
          opts.on_stage_mask
          opts.on_solved_mask

          opts.on(
            '-a', '--algorithm [ALGORITHM]', String,
            'Algorithm to be applied before visualization.'
          ) do |a|
            options.algorithm = parse_algorithm(a)
          end
        end.parse!(args)
        options
      end
    end
  end
end
