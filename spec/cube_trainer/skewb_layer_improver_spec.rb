# frozen_string_literal: true

require 'cube_trainer/skewb_layer_improver'
require 'twisty_puzzles'

describe SkewbLayerImprover do
  include TwistyPuzzles

  let(:face) { TwistyPuzzles::Face::U }
  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:improver) { described_class.new(face, color_scheme) }
  let(:sarah) { TwistyPuzzles::SkewbNotation.sarah }

  it 'finds a better layer for an ugly move' do
    expect(
      improver.improve_layer(parse_skewb_algorithm('B', sarah))
    ).to eq_sarahs_skewb_algorithm("R'")
  end
end
