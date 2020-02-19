# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'cube_trainer/cube_trainer_options_parser'
require 'ostruct'

module CubeTrainer
  module Anki
    # Command line options for the `cube_visualizer` binary.
    class CubeVisualizerOptions
      extend Core

      def self.default_options
        options = OpenStruct.new
        options.color_scheme = ColorScheme::BERNHARD
        options.cube_size = 3
        options.algorithm = Core::Algorithm.empty
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

          opts.on('-a', '--algorithm [ALGORITHM]', String,
                  'Algorithm to be applied before visualization.') do |a|
            options.algorithm = parse_algorithm(a)
          end
        end.parse!(args)
        options
      end
    end
  end
end
