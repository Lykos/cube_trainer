# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/cube_trainer_options_parser'
require 'ostruct'

module CubeTrainer
  # Command line options for the skewb layer searcher binary.
  class SkewbLayerSearcherOptions
    def self.default_options
      options = OpenStruct.new
      options.color_scheme = TwistyPuzzles::ColorScheme::BERNHARD
      options.letter_scheme = BernhardTwistyPuzzles::LetterScheme.new
      options
    end

    # rubocop:disable Metrics/MethodLength
    def self.parse(args)
      options = default_options

      CubeTrainerOptionsParser.new(options) do |opts|
        opts.on_output('anki deck file')

        opts.on(
          '-d', '--depth [DEPTH]', Integer,
          'Maximum search depth. Infinite if this is not set.'
        ) do |d|
          options.depth = d
        end

        opts.on(
          '-l', '--[no-]layer-corners-as-letters',
          'Show layer corners as letters instead of something like DRF.'
        ) do |l|
          options.layer_corners_as_letters = l
        end

        opts.on(
          '-t', '--[no-]top-corners-as-letters',
          'Show top corners as letters instead of something like URF.'
        ) do |t|
          options.top_corners_as_letters = t
        end

        opts.on(
          '-n', '--name_file [FILE]', String,
          'CSV file with a mapping from layer piece letter sequences to names.'
        ) do |n|
          options.name_file = n
        end
      end.parse!(args)
      options
    end
    # rubocop:enable Metrics/MethodLength
  end
end
