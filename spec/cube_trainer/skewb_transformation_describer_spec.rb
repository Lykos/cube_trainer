# frozen_string_literal: true

require 'cube_trainer/skewb_transformation_describer'
require 'twisty_puzzles'

CYCLE_REGEXP = Regexp.new("#{SkewbTransformationDescriber::DOUBLE_ARROW}|" \
                          "#{SkewbTransformationDescriber::ARROW}| <-> | -> ")

def canonicalize_transformation_descriptions(transformation_descriptions)
  transformation_descriptions.map do |s|
    parts = s.to_s.split(CYCLE_REGEXP)
    if parts.length == 1
      parts
    else
      parts = parts[0..-2] if parts[0] == parts[-1]
      parts.rotate(parts.index(parts.min))
    end
  end.sort
end

RSpec::Matchers.define(:be_the_same_descriptions_as) do |expected|
  match do |actual|
    canonicalize_transformation_descriptions(expected) ==
      canonicalize_transformation_descriptions(actual)
  end
end

describe SkewbTransformationDescriber do
  include TwistyPuzzles

  let(:top_corners) { TwistyPuzzles::Corner::ELEMENTS.select { |c| c.face_symbols.first == :U } }
  let(:bottom_corners) { TwistyPuzzles::Corner::ELEMENTS.select { |c| c.face_symbols.first == :D } }
  let(:non_bottom_faces) { TwistyPuzzles::Face::ELEMENTS.reject { |c| c.face_symbol == :D } }
  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:top_corners_describer) do
    described_class.new([], top_corners, :show_staying, color_scheme)
  end
  let(:centers_describer) do
    described_class.new(non_bottom_faces, [], :omit_staying, color_scheme)
  end
  let(:bottom_describer) do
    described_class.new([], bottom_corners, :omit_staying, color_scheme)
  end
  let(:sarah) { TwistyPuzzles::SkewbNotation.sarah }

  it 'describes center transformations of sledges accurately' do
    alg = parse_skewb_algorithm("F' L F L'", sarah)
    center_descriptions = centers_describer.transformation_descriptions(alg)
    expect(center_descriptions).to be_the_same_descriptions_as(['F <-> U', 'R <-> L'])
  end

  it 'describes center transformations of F moves accurately' do
    alg = parse_skewb_algorithm('F', sarah)
    center_descriptions = centers_describer.transformation_descriptions(alg)
    expect(center_descriptions).to be_the_same_descriptions_as(['U -> R -> F -> U'])
  end

  it 'describes corner transformations of sledges accurately' do
    alg = parse_skewb_algorithm("F' L F L'", sarah)
    top_corners_descriptions = top_corners_describer.source_descriptions(alg)
    expected_descriptions = ['FLU -> UFL', 'RFU -> URF', 'BUL -> ULB', 'RUB -> UBR']
    expect(top_corners_descriptions).to be_the_same_descriptions_as(expected_descriptions)
  end

  it 'describes corner transformations of F moves accurately' do
    alg = parse_skewb_algorithm('F', sarah)
    top_corners_descriptions = top_corners_describer.source_descriptions(alg)
    expected_descriptions = ['FUR -> URF', 'FLU -> UBR', 'FRD -> UFL', 'ULB stays']
    expect(top_corners_descriptions).to be_the_same_descriptions_as(expected_descriptions)
  end

  it 'describes sources of layer corners after sledges accurately' do
    alg = parse_skewb_algorithm("F' L F L'", sarah)
    expect(bottom_describer.source_descriptions(alg)).to be_the_same_descriptions_as([])
  end

  it 'describes sources of layer corners after F moves accurately' do
    alg = parse_skewb_algorithm('F', sarah)
    expect(bottom_describer.source_descriptions(alg)).to be_the_same_descriptions_as(['BRU -> DFR'])
  end
end
