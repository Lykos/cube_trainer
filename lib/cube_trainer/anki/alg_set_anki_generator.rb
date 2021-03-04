# frozen_string_literal: true

require 'csv'
require 'cube_trainer/training/alg_hint_parser'
require 'cube_trainer/anki/external_alg_set_parser'
require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/anki/note_input'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'
require 'net/http'
require 'parallel'
require 'set'
require 'fileutils'

module CubeTrainer
  module Anki
    # Class that generates an Anki deck for an alg set.
    class AlgSetAnkiGenerator
      include TwistyPuzzles::Utils::ArrayHelper
      FORMAT = :jpg
      NON_ZERO_AUFS = TwistyPuzzles::CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
        TwistyPuzzles::Algorithm.move(TwistyPuzzles::FatMove.new(TwistyPuzzles::Face::U, d))
      end.freeze
      AUFS = ([TwistyPuzzles::Algorithm::EMPTY] + NON_ZERO_AUFS).freeze
      # rubocop:disable Style/StringHashKeys
      LETTER_REPLACEMENTS = {
        'ä' => 'ae',
        'ö' => 'oe',
        'ü' => 'ue',
        'Ä' => 'Ae',
        'Ö' => 'Oe',
        'Ü' => 'Ue',
        'è' => 'e',
        'ß' => 'ss',
        /\s/ => '_',
        %r{[/()?"\\]} => '',
        "'" => '-'
      }.freeze
      # rubocop:enable Style/StringHashKeys

      def initialize(options, fetcher: Net::HTTP, checker: nil)
        check_output_dir('output', options.output_dir)
        check_output('output', options.output)

        @options = options
        @visualizer = CubeVisualizer.new(
          fetcher: fetcher,
          cache: create_cache,
          checker: checker,
          sch: options.color_scheme,
          fmt: FORMAT,
          stage: options.stage_mask
        )
        return unless @options.solved_mask_name

        @solved_mask = CubeMask.from_name(options.solved_mask_name, options.cube_size, :unknown)
      end

      def absolute_output_path(name)
        File.join(@options.output_dir, name)
      end

      def generate
        unless File.exist?(File.dirname(@options.output))
          FileUtils.mkpath(File.dirname(@options.output))
        end
        FileUtils.mkpath(@options.output_dir) unless File.exist?(@options.output_dir)
        CSV.open(@options.output, 'wb', col_sep: "\t") do |csv|
          generate_internal(csv)
        end
      end

      def aufs(alg)
        AUFS.map { |a| a + alg }
      end

      def use_internal_algs?
        raise ArgumentError if @options.alg_set && @options.input

        @options.alg_set
      end

      def internal_note_inputs
        raise ArgumentError unless @options.alg_set

        hints = Training::AlgHintParser.parse_hints(
          @options.alg_set, @options.cube_size,
          @options.verbose
        )
        hints.entries.map do |name, case_solution|
          alternative_algs = case_solution.alternative_algs.join("<br>")
          NoteInput.new(
            [name, case_solution.best_alg, alternative_algs], name,
            case_solution.best_alg
          )
        end
      end

      def external_note_inputs
        raise ArgumentError unless @options.input && @options.alg_column && @options.name_column

        ExternalAlgSetParser.parse(@options.input, @options.alg_column, @options.name_column)
      end

      def input_variations_with_auf(basic_note_inputs)
        basic_note_inputs.collect_concat do |input|
          AUFS.map.with_index do |auf, index|
            filename = new_image_filename(input.name, index)
            NoteInputVariation.new(
              input.fields, input.name, auf + input.alg,
              filename, img(filename)
            )
          end
        end
      end

      def input_variations_without_auf(basic_note_inputs)
        basic_note_inputs.map do |input|
          filename = new_image_filename(input.name)
          NoteInputVariation.new(input.fields, input.name, input.alg, filename, img(filename))
        end
      end

      def note_inputs
        basic_note_inputs =
          if use_internal_algs?
            internal_note_inputs
          else
            external_note_inputs
          end
        if @options.auf
          input_variations_with_auf(basic_note_inputs)
        else
          input_variations_without_auf(basic_note_inputs)
        end
      end

      def name_to_alg
        @name_to_alg ||= {}
      end

      # Make an alg name simple enough so we can use it as a file name without problems.
      def new_image_filename(alg_name, variation_index = '')
        name = alg_name.to_s.dup
        LETTER_REPLACEMENTS.each { |k, v| name.gsub!(k, v) }
        name = "alg_#{name}#{variation_index}.#{FORMAT}"
        unless name.ascii_only?
          raise ArgumentError, "Even with some replacements, we couldn't transform #{alg_name} " \
                               'to an ASCII-only string.'
        end
        if name_to_alg[name]
          raise ArgumentError,
                "Two algs map to file name #{name}: #{alg_name} and #{name_to_alg[name]}"
        end

        name_to_alg[name] = alg_name
        name
      end

      def img(source)
        raise ArgumentError, "Got bad filename #{source}" unless /^[\w.+-]+$/.match?(source)

        # TODO: This is bad, but works with our restriction.
        "<img src='#{source}'/>"
      end

      # Note that this will be called in parallel, so it needs to be thread-safe.
      def process_note_input(note_input)
        state = @options.color_scheme.solved_cube_state(@options.cube_size)
        @solved_mask&.apply_to(state)
        note_input.modified_alg.inverse.apply_to(state)
        @visualizer.fetch_and_store(state, absolute_output_path(note_input.image_filename))
      end

      def generate_internal(csv)
        inputs = note_inputs
        Parallel.each(
          inputs,
          progress: @options.verbose ? "Fetching #{inputs.length} alg images" : nil,
          in_threads: 50
        ) { |note_input| process_note_input(note_input) }
        inputs.group_by(&:name).each do |_name, values|
          fields = values[0].fields
          csv << fields + values.map(&:img)
        end
      end

      # Wrapper around a cache that emulates a simplified #fetch method.
      # TODO: Remove when the FileStore cache fixed their bug in #fetch.
      class CacheFetchWrapper
        def initialize(cache)
          @cache = cache
        end

        def fetch(key)
          r = @cache.read(key)
          return r if r

          r = yield
          @cache.write(key, r)
          r
        end
      end

      def create_cache
        return unless @options.cache

        check_output_dir('cache', @options.cache_dir)
        FileUtils.mkpath(@options.cache_dir) unless File.exist?(@options.cache_dir)
        CacheFetchWrapper.new(ActiveSupport::Cache::FileStore.new(@options.cache_dir))
      end

      def first_existing_ancestor(directory)
        until File.exist?(directory)
          parent = File.dirname(directory)
          raise if parent == directory

          directory = parent
        end
        directory
      end

      def check_output_dir(output_dir_name, output_dir)
        unless output_dir.is_a?(String)
          raise TypeError,
                "#{output_dir_name} directory is not a string."
        end

        ancestor = first_existing_ancestor(output_dir)
        raise ArgumentError unless File.directory?(ancestor)
        raise ArgumentError unless File.writable?(ancestor)
      end

      def check_output(output_name, output)
        raise TypeError, "#{output_name} is not a string." unless output.is_a?(String)

        check_output_dir(output_name, File.dirname(output))
        raise ArgumentError, "#{output_name} is a directory" if File.directory?(output)

        return unless File.exist?(output) && !File.writable?(output)

        raise ArgumentError, "#{output_name} is not writeable"
      end
    end
  end
end
