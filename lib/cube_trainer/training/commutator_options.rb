# frozen_string_literal: true

require 'ostruct'
require 'cube_trainer/color_scheme'
require 'cube_trainer/cube_trainer_options_parser'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/training/commutator_types'

module CubeTrainer
  module Training
    # Command line options for `commutators` binary.
    class CommutatorOptions
      include CommutatorTypes

      def self.default_options
        options = OpenStruct.new
        options.known = false
        options.commutator_info = COMMUTATOR_TYPES['corners']
        options.restrict_letters = nil
        options.exclude_letters = []
        options.letter_scheme = BernhardLetterScheme.new
        options.color_scheme = ColorScheme::BERNHARD
        options.restrict_colors = options.color_scheme.colors
        options.picture = false
        options.mute = false
        options.buffer = nil
        options.test_comms_mode = :ignore
        options
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.parse(args)
        options = default_options

        # rubocop:disable Metrics/BlockLength
        CubeTrainerOptionsParser.new(options) do |opts|
          opts.on_size

          opts.on(
            '-c', '--commutator_type TYPE', COMMUTATOR_TYPES,
            'Use the given type of commutators for training.'
          ) do |c|
            options.commutator_info = c
            if options.cube_size.nil? && !c.default_cube_size.nil?
              options.cube_size = c.default_cube_size
            end
          end

          opts.on(
            '-t', '--test_comms_mode [MODE]', CommutatorHintParser::TEST_COMMS_MODES,
            'Test commutators mode at startup.'
          ) do |t|
            options.test_comms_mode = t
          end

          opts.on('-i', '--memo_time_s TIME', Float, 'The desired memo time.') do |i|
            unless i.positive?
              warn 'Memo time has to be positive.'
              exit(1)
            end

            options.memo_time_s = i
          end

          opts.on(
            '-b', '--buffer BUFFER', /\w+/,
            'Buffer to use instead of the default one.'
          ) do |b|
            options.buffer = b
          end

          opts.on(
            '-x', '--restrict_colors COLORLIST', /[yrbgow]+/,
            'Restrict colors to find a layer for.'
          ) do |colors|
            options.restrict_colors =
              colors.each_char.map do |c|
                options.color_scheme.colors.find { |o| o.to_s[0] == c }
              end
          end

          opts.on(
            '-p', '--[no-]picture',
            'Show a picture of the cube instead of the letter pair.'
          ) do |p|
            options.picture = p
          end

          opts.on(
            '-k', '--[no-]known',
            'This alg set is known to the user. Turns off introducing items slowly and repeating ' \
            'new ones.'
          ) do |k|
            options.known = k
          end

          opts.on('-m', '--[no-]mute', 'Mute (i.e. no audio).') do |m|
            options.mute = m
          end

          opts.on(
            '-r', '--restrict_letters LETTERLIST', /\w+/,
            'List of letters to which the commutators should be restricted.',
            '  (Only uses commutators that contain at least one of the given ' \
            'letters)'
          ) do |letters|
            options.restrict_letters = letters.downcase.split('')
          end

          opts.on(
            '-e', '--exclude_letters LETTERLIST', /\w+/,
            'List of letters which should be excluded for commutators.',
            '  (Only uses commutators that contain none of the given letters)'
          ) do |letters|
            options.exclude_letters = letters.downcase.split('')
          end
        end.parse!(args)
        # rubocop:enable Metrics/BlockLength
        unless options.commutator_info
          warn 'Option --commutator_type is required.'
          exit(1)
        end

        options
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end
