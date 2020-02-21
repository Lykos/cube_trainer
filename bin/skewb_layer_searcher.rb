#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/skewb_layer_classifier'
require 'cube_trainer/skewb_layer_improver'
require 'cube_trainer/skewb_layer_searcher'
require 'cube_trainer/skewb_transformation_describer'
require 'cube_trainer/skewb_layer_searcher_options'
require 'csv'

TITLE_ROW = [
  'case description',
  'main alg',
  'center_transformations',
  'top_corner_transformations',
  'alternative algs',
  'name',
  'tags'
].freeze

options = CubeTrainer::SkewbLayerSearcherOptions.parse(ARGV)
solutions = CubeTrainer::SkewbLayerSearcher.calculate(
  options.color_scheme,
  options.verbose,
  options.depth
)
layer_improver = CubeTrainer::SkewbLayerImprover.new(
  CubeTrainer::Core::Face::D,
  options.color_scheme
)
solutions =
  solutions.map do |algs|
    algs.map { |alg| layer_improver.improve_layer(alg) }
  end

if options.verbose
  puts
  puts "#{solutions.length} solutions:"
  puts

  state = options.color_scheme.solved_skewb_state
  solutions.each do |algs|
    algs.first.inverse.apply_temporarily_to(state) do
      puts state.colored_to_s
      puts algs
      puts
    end
  end
end

if options.output
  puts
  names = {}
  if options.name_file
    puts "Reading name TSV file #{options.name_file}."
    CSV.foreach(options.name_file, col_sep: "\t") do |csv|
      names[csv[0]] = csv[1]
    end
    puts "Read #{names.length} names."
  end
  state = options.color_scheme.solved_skewb_state
  top_corners = CubeTrainer::Core::Corner::ELEMENTS.select { |c| c.face_symbols.first == :U }
  bottom_corners = CubeTrainer::Core::Corner::ELEMENTS.select { |c| c.face_symbols.first == :D }
  non_bottom_faces = CubeTrainer::Core::Face::ELEMENTS.reject { |c| c.face_symbol == :D }
  layer_corners_letter_scheme = options.layer_corners_as_letters ? options.letter_scheme : nil
  layer_describer = CubeTrainer::Core::SkewbTransformationDescriber.new(
    [], bottom_corners, :omit_staying, options.color_scheme, layer_corners_letter_scheme
  )
  center_describer = CubeTrainer::Core::SkewbTransformationDescriber.new(
    non_bottom_faces, [], :omit_staying, options.color_scheme
  )
  top_corners_letter_scheme = options.top_corners_as_letters ? options.letter_scheme : nil
  top_corner_describer = CubeTrainer::Core::SkewbTransformationDescriber.new(
    [], top_corners, :show_staying, options.color_scheme, top_corners_letter_scheme
  )
  layer_classifier = CubeTrainer::Core::SkewbLayerClassifier.new(
    CubeTrainer::Core::Face::D,
    options.color_scheme
  )

  CSV.open(options.output, 'wb', col_sep: "\t") do |csv|
    csv << TITLE_ROW
    solutions.each do |algs|
      main_alg = algs[0]
      alternative_algs = algs[1..-1]
      classification = layer_classifier.classify_layer(algs[0])
      source_descriptions = layer_describer.source_descriptions(main_alg)
      name_letters =
        source_descriptions.map(&:source).map do |p|
          options.letter_scheme.letter(p).capitalize
        end
      letter_pairs = name_letters.each_slice(2).map(&:join)
      name = letter_pairs.map do |letter_pair|
        key = letter_pair.length == 2 ? letter_pair : letter_pair * 2
        name = names[key] || letter_pair
      end.join(' & ')
      csv << [
        source_descriptions.join(', '),
        main_alg.to_s,
        center_describer.transformation_descriptions(main_alg).join(', '),
        top_corner_describer.source_descriptions(main_alg).join(', '),
        alternative_algs.join(', '),
        name,
        "#{main_alg.length}_mover #{classification}"
      ]
    end
  end
  puts "Wrote #{solutions.length} items to TSV file #{options.output}."
end
