#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/cube'
require 'cube_trainer/skewb_layer_classifier'
require 'cube_trainer/skewb_layer_improver'
require 'cube_trainer/skewb_layer_searcher'
require 'cube_trainer/skewb_transformation_describer'
require 'cube_trainer/skewb_state'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/skewb_layer_searcher_options'
require 'csv'

include CubeTrainer
include CubePrintHelper

options = SkewbLayerSearcherOptions.parse(ARGV)
solutions = SkewbLayerSearcher.calculate(options.color_scheme, options.verbose, options.depth)
layer_improver = SkewbLayerImprover.new(Face::D, options.color_scheme)
solutions = solutions.map do |algs|
  algs.map { |alg| layer_improver.improve_layer(alg) }
end.sort_by { |algs| algs[0] }

if options.verbose
  puts
  puts "#{solutions.length} solutions:" 
  puts

  state = options.color_scheme.solved_skewb_state
  solutions.each do |algs|
    algs.first.inverse.apply_temporarily_to(state) do
      puts skewb_string(state, :color)
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
  top_corners = Corner::ELEMENTS.select { |c| c.face_symbol.first == :U }
  bottom_corners = Corner::ELEMENTS.select { |c| c.face_symbol.first == :D }
  non_bottom_faces = Face::ELEMENTS.select { |c| c.face_symbol != :D }
  layer_corners_letter_scheme = if options.layer_corners_as_letters then options.letter_scheme else nil end
  layer_describer = SkewbTransformationDescriber.new([], bottom_corners, :omit_staying, layer_corners_letter_scheme)
  center_describer = SkewbTransformationDescriber.new(non_bottom_faces, [], :omit_staying)
  top_corners_letter_scheme = if options.top_corners_as_letters then options.letter_scheme else nil end
  top_corner_describer = SkewbTransformationDescriber.new([], top_corners, :show_staying, top_corners_letter_scheme)
  layer_classifier = SkewbLayerClassifier.new(Face::D, options.color_scheme)

  CSV.open(options.output, 'wb', {:col_sep => "\t"}) do |csv|
    csv << ['case description', 'main alg', 'center_transformations', 'top_corner_transformations', 'alternative algs', 'name', 'tags']
    solutions.each do |algs|
      main_alg, alternative_algs = algs[0], algs[1..-1]
      classification = layer_classifier.classify_layer(algs[0])
      source_descriptions = layer_describer.source_descriptions(main_alg)
      name_letters = source_descriptions.map { |d| d.source }.map { |p| options.letter_scheme.letter(p).capitalize }
      letter_pairs = name_letters.each_slice(2).map { |ls| ls.join }
      name = letter_pairs.map do |letter_pair|
        key = if letter_pair.length == 2 then letter_pair else letter_pair * 2 end
        name = names[key] || letter_pair
      end.join(" & ")
      csv << [
        source_descriptions.join(", "),
        main_alg.to_s,
        center_describer.transformation_descriptions(main_alg).join(", "),
        top_corner_describer.source_descriptions(main_alg).join(", "),
        alternative_algs.join(', '),
        name,
        "#{main_alg.length}_mover #{classification}"
      ]
    end
  end
  puts "Wrote #{solutions.length} items to TSV file #{options.output}."
end
