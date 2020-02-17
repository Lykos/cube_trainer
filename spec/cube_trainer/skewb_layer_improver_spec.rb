# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/parser'
require 'cube_trainer/skewb_layer_improver'

describe SkewbLayerImprover do
  include Core

  let(:face) { Core::Face::U }
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:improver) { SkewbLayerImprover.new(face, color_scheme) }

  it 'should find a better layer for an ugly move' do
    expect(improver.improve_layer(parse_sarahs_skewb_algorithm('B'))).to be == parse_sarahs_skewb_algorithm("R'")
  end
end
