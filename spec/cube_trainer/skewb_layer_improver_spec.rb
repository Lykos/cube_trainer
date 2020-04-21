# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/skewb_layer_improver'

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
