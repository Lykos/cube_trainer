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
    class AlgSetAnkiGenerator
      include ArrayHelper

      FORMAT = :jpg
      AUFS = [Algorithm.empty] + CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Algorithm.move(FatMove.new(Face::U, d)) }

      def initialize(options)
        unless File.exist?(options.output_dir) && File.directory?(options.output_dir) && File.writable?(options.output_dir)
          raise ArgumentError
      end

        @options = options
        cache = options.cache ? Cache.new('cube_visualizer') : nil
        @visualizer = CubeVisualizer.new(fetcher: Net::HTTP, cache: cache, sch: options.color_scheme, fmt: FORMAT, stage: options.stage_mask)
        if @options.solved_mask_name
          @solved_mask = CubeMask.from_name(options.solved_mask_name, options.cube_size, :unknown)
        end
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

        AlgHintParser.parse_hints(@options.alg_set, @options.verbose).entries.map { |name, alg| NoteInput.new([name, alg], name, alg) }
      end

      def external_note_inputs
        raise ArgumentError unless @options.input && @options.alg_column && @options.name_column

        AlgSetParser.parse(@options.input, @options.alg_column, @options.name_column)
      end

      def note_inputs
        basic_note_inputs = if use_internal_algs?
                              internal_note_inputs
                            else
                              external_note_inputs
                            end
        if @options.auf
          basic_note_inputs.collect_concat do |input|
            AUFS.map.with_index do |auf, index|
              filename = new_image_filename(input.name, index)
              NoteInputVariation.new(input.fields, input.name, auf + input.alg, filename, img(filename))
            end
          end
        else
          basic_note_inputs.map do |input|
            filename = new_image_filename(input.name)
            NoteInputVariation.new(input.fields, input.name, input.alg, filename, img(filename))
          end
        end
      end

      def name_to_alg
        @name_to_alg ||= {}
      end

      # Make an alg name simple enough so we can use it as a file name without problems.
      # TODO This is broken
      def new_image_filename(alg_name, variation_index = '')
        name = "alg_#{alg_name}#{variation_index}.#{FORMAT}"
               .gsub(/\s/, '_')
               .gsub(%r{[/()?]}, '')
               .gsub("'", '-')
               .gsub('ä', 'ae')
               .gsub('ö', 'oe')
               .gsub('ü', 'ue')
               .gsub('Ä', 'Ae')
               .gsub('Ö', 'Oe')
               .gsub('Ü', 'Ue')
               .gsub('è', 'e')
               .gsub('ß', 'ss')
        if name_to_alg[name]
          raise ArgumentError, "Two algs map to file name #{name}: #{alg_name} and #{name_to_alg[name]}"
      end

        name_to_alg[name] = alg_name
        name
      end

      def img(source)
        raise ArgumentError, "Got bad filename #{source}" unless source =~ /^[\w.+-]+$/

        # TODO: This is bad, but works with our restriction.
        "<img src='#{source}'/>"
      end

      def generate_internal(csv)
        Parallel.map(note_inputs, progress: 'Fetching alg images', in_threads: 50) do |note_input|
          state = @options.color_scheme.solved_cube_state(@options.cube_size)
          @solved_mask.apply_to(state) if @solved_mask
          note_input.modified_alg.inverse.apply_to(state)
          @visualizer.fetch_and_store(state, absolute_output_path(note_input.image_filename))
          note_input
        end.group_by(&:name).map do |_name, values|
          fields = values[0].fields
          csv << fields + values.map(&:img)
        end
      end
    end
  end
end
