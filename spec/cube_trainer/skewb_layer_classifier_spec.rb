# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/skewb_layer_classifier'

describe SkewbLayerClassifier do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:classifier) { described_class.new(Core::Face::D, color_scheme) }
  let(:sarah) { Core::SkewbNotation.sarah }

  it 'classifies the solved layer correctly' do
    expect(classifier.classify_layer(Core::Algorithm::EMPTY)).to be == '4_solved'
    expect(classifier.classify_layer(parse_skewb_algorithm("R' F R F'", sarah))).to be == '4_solved'
  end

  it 'classifies a one move layer correctly' do
    expect(classifier.classify_layer(parse_skewb_algorithm('R', sarah))).to be == '3_solved'
  end

  it 'classifies a two opposite solved layer correctly' do
    expect(classifier.classify_layer(parse_skewb_algorithm('R L', sarah))).to be == '2_opposite_solved'
  end

  it 'classifies a two adjacent solved layer correctly' do
    expect(classifier.classify_layer(parse_skewb_algorithm('F L', sarah))).to be == '2_adjacent_solved'
  end

  it 'classifies a layer with one solved piece correctly' do
    expect(classifier.classify_layer(parse_skewb_algorithm('F L R', sarah))).to be == '1_solved'
  end

  it 'classifies a layer with no solved piece correctly' do
    expect(classifier.classify_layer(parse_skewb_algorithm('F L R B', sarah))).to be == '0_solved'
  end
end
