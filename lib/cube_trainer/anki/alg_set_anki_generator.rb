# frozen_string_literal: true

require 'csv'
require 'cube_trainer/anki/alg_set_parser'
require 'cube_trainer/anki/cache'
require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/anki/note_input'
require 'cube_trainer/core/move'
require 'cube_trainer/core/direction'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/utils/array_helper'
require 'net/http'
require 'parallel'
require 'set'

module CubeTrainer
  module Anki
    # Class that generates an Anki deck for an alg set.
    class AlgSetAnkiGenerator
      include Utils::ArrayHelper
      AUFS = ([Core::Algorithm::EMPTY] + NON_ZERO_AUFS).freeze
      FORMAT = :jpg
      NON_ZERO_AUFS = Core::CubeDirection::NON_ZERO_DIRECTIONS.map do |d|
        Core::Algorithm.move(Core::FatMove.new(Core::Face::U, d))
      end.freeze
      ALG_NAME_REPLACEMENTS = {
        :ä => 'ae',
        :ö => 'oe',
        :ü => 'ue',
        :Ä => 'Ae',
        :Ö => 'Oe',
        :Ü => 'Ue',
        :è => 'e',
        :ß => 'ss',
        /\s/ => '_',
        %r{[/()?"\\]} => '',
        :"'" => '-'
      }.freeze
      ALG_NAME_REPLACEMENTS = {
        :ä => 'ae',
        :ö => 'oe',
        :ü => 'ue',
        :Ä => 'Ae',
        :Ö => 'Oe',
        :Ü => 'Ue',
        :è => 'e',
        :ß => 'ss',
        /\s/ => '_',
        %r{[/()?"\\]} => '',
        :"'" => '-'
      }.freeze
      def initialize(options)
        check_output_dir(options.output_dir)
        check_output(options.output)

        @options = options
        @visualizer = CubeVisualizer.new(
          fetcher: Net::HTTP,
          cache: create_cache(options),
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

        AlgHintParser.parse_hints(@options.alg_set, @options.verbose).entries.map do |name, alg|
          NoteInput.new([name, alg], name, alg)
        end
      end

      def external_note_inputs
        raise ArgumentError unless @options.input && @options.alg_column && @options.name_column

        AlgSetParser.parse(@options.input, @options.alg_column, @options.name_column)
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
      # TODO This is broken
      def new_image_filename(alg_name, variation_index = '')
        LETTER_REPLACEMENTS.each { |k, v| alg_name.gsub!(k, v) }
        name = "alg_#{alg_name}#{variation_index}.#{FORMAT}"
        if name_to_alg[name]
          raise ArgumentError,
                "Two algs map to file name #{name}: #{alg_name} and #{name_to_alg[name]}"
        end

        name_to_alg[name] = alg_name
        name
      end

      def img(source)
        raise ArgumentError, "Got bad filename #{source}" unless source =~ /^[\w.+-]+$/

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
        Parallel.each(
          note_inputs,
          progress: 'Fetching alg images',
          in_threads: 50
        ) { |note_input| process_note_input(note_input) }
        note_inputs.group_by(&:name).each do |_name, values|
          fields = values[0].fields
          csv << fields + values.map(&:img)
        end
      end

      def create_cache(options)
        options.cache ? Cache.new('cube_visualizer') : nil
      end

      def check_output_dir(output_dir)
        raise TypeError unless output_dir.is_a?(String)
        raise ArgumentError unless File.exist?(output_dir)
        raise ArgumentError unless File.directory?(output_dir)
        raise ArgumentError unless File.writable?(output_dir)
      end

      def check_output(output)
        raise TypeError unless output.is_a?(String)

        check_output_dir(File.dirname(output))
        raise ArgumentError if File.directory?(output)
        raise ArgumentError if File.exist?(output) && !File.writable?(output)
      end
    end
  end
end
