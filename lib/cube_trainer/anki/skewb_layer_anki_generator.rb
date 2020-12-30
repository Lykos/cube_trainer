# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/skewb_layer_classifier'
require 'cube_trainer/skewb_layer_improver'
require 'cube_trainer/skewb_layer_searcher'
require 'cube_trainer/skewb_transformation_describer'
require 'csv'

module CubeTrainer
  module Anki
    # Generates an Anki deck for Skewb layer cases.
    class SkewbLayerAnkiGenerator
      TITLE_ROW = [
        'case description',
        'main alg',
        'center_transformations',
        'top_corner_transformations',
        'alternative algs',
        'name',
        'tags'
      ].freeze

      TOP_CORNERS = TwistyPuzzles::Corner::ELEMENTS.select { |c| c.face_symbols.first == :U }.freeze
      BOTTOM_CORNERS =
        TwistyPuzzles::Corner::ELEMENTS.select { |c| c.face_symbols.first == :D }.freeze
      NON_BOTTOM_FACES = TwistyPuzzles::Face::ELEMENTS.reject { |c| c.face_symbol == :D }.freeze

      def initialize(options)
        @options = options
      end

      def calculate
        SkewbLayerSearcher.calculate(
          @options.color_scheme,
          @options.verbose,
          @options.depth
        ).map! do |algs|
          algs.map! { |alg| layer_improver.improve_layer(alg) }
        end
      end

      def layer_improver
        @layer_improver ||= SkewbLayerImprover.new(
          TwistyPuzzles::Face::D,
          @options.color_scheme
        )
      end

      def report_solutions(solutions)
        return unless verbose

        puts
        puts "#{solutions.length} solutions:"
        puts

        state = @options.color_scheme.solved_skewb_state
        solutions.each do |algs|
          algs.first.inverse.apply_temporarily_to(state) do |s|
            puts s.colored_to_s
            puts algs
            puts
          end
        end
      end

      def verbose
        @options.verbose
      end

      def names
        @names ||=
          begin
            names = {}

            if @options.name_file
              puts "Reading name TSV file #{@options.name_file}." if verbose
              CSV.foreach(@options.name_file, col_sep: "\t") do |csv|
                names[csv[0]] = csv[1]
              end
              puts "Read #{names.length} names." if verbose
            end
            names
          end
      end

      def layer_describer
        @layer_describer ||=
          begin
            letter_scheme = @options.layer_corners_as_letters ? @options.letter_scheme : nil
            SkewbTransformationDescriber.new(
              [], BOTTOM_CORNERS, :omit_staying, @options.color_scheme, letter_scheme
            )
          end
      end

      def center_describer
        @center_describer ||= SkewbTransformationDescriber.new(
          NON_BOTTOM_FACES, [], :omit_staying, @options.color_scheme
        )
      end

      def top_corner_describer
        @top_corner_describer ||=
          begin
            letter_scheme = @options.top_corners_as_letters ? @options.letter_scheme : nil
            SkewbTransformationDescriber.new(
              [], TOP_CORNERS, :show_staying, @options.color_scheme, letter_scheme
            )
          end
      end

      def layer_classifier
        @layer_classifier ||= SkewbLayerClassifier.new(
          TwistyPuzzles::Face::D,
          @options.color_scheme
        )
      end

      def name(source_descriptions)
        name_letters =
          source_descriptions.map(&:source).map do |p|
            @options.letter_scheme.letter(p).capitalize
          end
        letter_pairs = name_letters.each_slice(2).map(&:join)
        letter_pairs.map do |letter_pair|
          key = letter_pair.length == 2 ? letter_pair : letter_pair * 2
          names[key] || letter_pair
        end.join(' & ')
      end

      def alg_row(algs)
        main_alg = algs[0]
        alternative_algs = algs[1..-1]
        classification = layer_classifier.classify_layer(algs[0])
        source_descriptions = layer_describer.source_descriptions(main_alg)
        name = name(source_descriptions)
        [
          source_descriptions.join(', '),
          main_alg.to_s,
          center_describer.transformation_descriptions(main_alg).join(', '),
          top_corner_describer.source_descriptions(main_alg).join(', '),
          alternative_algs.join(', '),
          name,
          "#{main_alg.length}_mover #{classification}"
        ]
      end

      def output(solutions)
        return unless @options.output

        puts if verbose

        CSV.open(@options.output, 'wb', col_sep: "\t") do |csv|
          csv << TITLE_ROW
          solutions.each do |algs|
            csv << alg_row(algs)
          end
        end
        puts "Wrote #{solutions.length} items to TSV file #{@options.output}." if verbose
      end

      def run
        solutions = calculate
        report_solutions(solutions)
        output(solutions)
      end
    end
  end
end
