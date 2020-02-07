require 'cube_trainer/skewb_layer_improver'
require 'cube_trainer/cube'
require 'cube_trainer/parser'
require 'cube_trainer/color_scheme'

describe SkewbLayerImprover do

  let (:face) { Face::U }
  let (:color_scheme) { ColorScheme::BERNHARD }
  let (:improver) { SkewbLayerImprover.new(face, color_scheme) }

  it 'should find a better layer for an ugly move' do
    expect(improver.improve_layer(parse_sarahs_skewb_algorithm("B"))).to be == parse_sarahs_skewb_algorithm("R'")
  end
  
end
