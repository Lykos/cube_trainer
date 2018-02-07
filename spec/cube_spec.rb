require 'cube'
require 'coordinate'

include CubeTrainer

RSpec::Matchers.define :be_rotationally_equivalent_to do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

RSpec.shared_examples 'Part' do |clazz|
  let(:letter) { ALPHABET.sample }
  
  it 'should find the piece with the right letter' do
    expect(clazz.for_letter(letter).letter).to be == letter
  end
end

describe Edge do
  it_behaves_like 'Part', Edge

  let(:cube_size) { 3 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }
    
  it 'returns the right solved_coordinate' do
    expect(Edge.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 1)
    expect(Edge.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 0)
    expect(Edge.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, -1)
    expect(Edge.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 1)
    expect(Edge.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 1)
    expect(Edge.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 0)
    expect(Edge.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, -1)
    expect(Edge.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 1)
    expect(Edge.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 1)
    expect(Edge.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 0)
    expect(Edge.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, -1)
    expect(Edge.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 1)
    expect(Edge.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 1)
    expect(Edge.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 0)
    expect(Edge.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, -1)
    expect(Edge.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 1)
    expect(Edge.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 1)
    expect(Edge.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 0)
    expect(Edge.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, -1)
    expect(Edge.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 1)
    expect(Edge.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 1)
    expect(Edge.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 0)
    expect(Edge.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, -1)
    expect(Edge.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 1)
  end
end

describe Midge do
  it_behaves_like 'Part', Midge

  let(:cube_size) { 5 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(Midge.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 2)
    expect(Midge.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 0)
    expect(Midge.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, -1)
    expect(Midge.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 2)
    expect(Midge.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 2)
    expect(Midge.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 0)
    expect(Midge.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, -1)
    expect(Midge.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 2)
    expect(Midge.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 2)
    expect(Midge.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 0)
    expect(Midge.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, -1)
    expect(Midge.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 2)
    expect(Midge.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 2)
    expect(Midge.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 0)
    expect(Midge.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, -1)
    expect(Midge.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 2)
    expect(Midge.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 2)
    expect(Midge.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 0)
    expect(Midge.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, -1)
    expect(Midge.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 2)
    expect(Midge.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 2)
    expect(Midge.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 0)
    expect(Midge.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, -1)
    expect(Midge.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 2)
  end
end

describe Wing do
  it_behaves_like 'Part', Wing

  let(:cube_size) { 4 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'should parse wings in UB correctly' do
    expect(Wing.parse('UBl')).to be == Wing.for_colors([:orange, :yellow])
    expect(Wing.parse('UBr')).to be == Wing.for_colors([:yellow, :orange])
    expect(Wing.parse('BUl')).to be == Wing.for_colors([:orange, :yellow])
    expect(Wing.parse('BUr')).to be == Wing.for_colors([:yellow, :orange])
  end

  it 'should parse wings in DB correctly' do
    expect(Wing.parse('DBL')).to be == Wing.for_colors([:white, :orange])
    expect(Wing.parse('DBR')).to be == Wing.for_colors([:orange, :white])
    expect(Wing.parse('BDL')).to be == Wing.for_colors([:white, :orange])
    expect(Wing.parse('BDR')).to be == Wing.for_colors([:orange, :white])
  end

  it 'should parse wings in UF correctly' do
    expect(Wing.parse('UFl')).to be == Wing.for_colors([:yellow, :red])
    expect(Wing.parse('UFr')).to be == Wing.for_colors([:red, :yellow])
    expect(Wing.parse('FUl')).to be == Wing.for_colors([:yellow, :red])
    expect(Wing.parse('FUr')).to be == Wing.for_colors([:red, :yellow])
  end

  it 'should parse wings in DF correctly' do
    expect(Wing.parse('DFl')).to be == Wing.for_colors([:red, :white])
    expect(Wing.parse('DFr')).to be == Wing.for_colors([:white, :red])
    expect(Wing.parse('FDl')).to be == Wing.for_colors([:red, :white])
    expect(Wing.parse('FDr')).to be == Wing.for_colors([:white, :red])
  end

  it 'should parse wings in UR correctly' do
    expect(Wing.parse('URb')).to be == Wing.for_colors([:green, :yellow])
    expect(Wing.parse('URf')).to be == Wing.for_colors([:yellow, :green])
    expect(Wing.parse('RUb')).to be == Wing.for_colors([:green, :yellow])
    expect(Wing.parse('RUf')).to be == Wing.for_colors([:yellow, :green])
  end

  it 'should parse wings in FR correctly' do
    expect(Wing.parse('FRu')).to be == Wing.for_colors([:green, :red])
    expect(Wing.parse('FRd')).to be == Wing.for_colors([:red, :green])
    expect(Wing.parse('RFu')).to be == Wing.for_colors([:green, :red])
    expect(Wing.parse('RFd')).to be == Wing.for_colors([:red, :green])
  end

  it 'returns the right solved_coordinate' do
    expect(Wing.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 2)
    expect(Wing.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 0)
    expect(Wing.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 3)
    expect(Wing.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 3, 1)
    expect(Wing.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 1)
    expect(Wing.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 0)
    expect(Wing.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 3)
    expect(Wing.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 3, 2)
    expect(Wing.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 2)
    expect(Wing.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 0)
    expect(Wing.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 3)
    expect(Wing.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 3, 1)
    expect(Wing.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 1)
    expect(Wing.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 0)
    expect(Wing.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 3)
    expect(Wing.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 3, 2)
    expect(Wing.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 2)
    expect(Wing.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 0)
    expect(Wing.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 3)
    expect(Wing.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 3, 1)
    expect(Wing.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 1)
    expect(Wing.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 0)
    expect(Wing.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 3)
    expect(Wing.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 3, 2)
  end
end

describe Corner do
  it_behaves_like 'Part', Corner

  let(:cube_size) { 3 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(Corner.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, -1)
    expect(Corner.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 0)
    expect(Corner.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, -1)
    expect(Corner.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 0)
    expect(Corner.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 0)
    expect(Corner.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 0)
    expect(Corner.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, -1)
    expect(Corner.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, -1)
    expect(Corner.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, -1)
    expect(Corner.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 0)
    expect(Corner.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, -1)
    expect(Corner.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 0)
    expect(Corner.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 0)
    expect(Corner.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 0)
    expect(Corner.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, -1)
    expect(Corner.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, -1)
    expect(Corner.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, -1)
    expect(Corner.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 0)
    expect(Corner.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, -1)
    expect(Corner.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 0)
    expect(Corner.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 0)
    expect(Corner.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 0)
    expect(Corner.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, -1)
    expect(Corner.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, -1)
  end
end

describe Face do
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'should return the right neighbor faces' do  
    expect(yellow_face.neighbors).to be_rotationally_equivalent_to [green_face, red_face, blue_face, orange_face]
    expect(white_face.neighbors).to be_rotationally_equivalent_to [red_face, green_face, orange_face, blue_face]
    expect(red_face.neighbors).to be_rotationally_equivalent_to [yellow_face, green_face, white_face, blue_face]
    expect(orange_face.neighbors).to be_rotationally_equivalent_to [green_face, yellow_face, blue_face, white_face]
    expect(green_face.neighbors).to be_rotationally_equivalent_to [red_face, yellow_face, orange_face, white_face]
    expect(blue_face.neighbors).to be_rotationally_equivalent_to [yellow_face, red_face, white_face, orange_face]
  end

  it 'should return the right axis priority' do
    expect(yellow_face.axis_priority).to be == 0
    expect(white_face.axis_priority).to be == 0
    expect(red_face.axis_priority).to be == 1
    expect(orange_face.axis_priority).to be == 1
    expect(green_face.axis_priority).to be == 2
    expect(blue_face.axis_priority).to be == 2
  end

  it 'should answer which faces are close to smaller indices' do
    expect(yellow_face.close_to_smaller_indices?).to be true
    expect(white_face.close_to_smaller_indices?).to be false
    expect(red_face.close_to_smaller_indices?).to be true
    expect(orange_face.close_to_smaller_indices?).to be false
    expect(green_face.close_to_smaller_indices?).to be true
    expect(blue_face.close_to_smaller_indices?).to be false
  end

end

describe TCenter do
  it_behaves_like 'Part', TCenter

  let(:cube_size) { 5 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(TCenter.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 2)
    expect(TCenter.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 1)
    expect(TCenter.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, -2)
    expect(TCenter.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, 2)
    expect(TCenter.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 2)
    expect(TCenter.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 1)
    expect(TCenter.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, -2)
    expect(TCenter.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, 2)
    expect(TCenter.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 2)
    expect(TCenter.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 1)
    expect(TCenter.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, -2)
    expect(TCenter.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, 2)
    expect(TCenter.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 2)
    expect(TCenter.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 1)
    expect(TCenter.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, -2)
    expect(TCenter.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, 2)
    expect(TCenter.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 2)
    expect(TCenter.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 1)
    expect(TCenter.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, -2)
    expect(TCenter.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, 2)
    expect(TCenter.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 2)
    expect(TCenter.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 1)
    expect(TCenter.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, -2)
    expect(TCenter.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, 2)
  end
end

describe XCenter do
  it_behaves_like 'Part', XCenter
  
  let(:cube_size) { 4 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }
  
  it 'returns the right solved_coordinate' do
    expect(XCenter.for_letter('a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, -2)
    expect(XCenter.for_letter('b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 1)
    expect(XCenter.for_letter('c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, -2)
    expect(XCenter.for_letter('d').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, 1)
    expect(XCenter.for_letter('e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 1)
    expect(XCenter.for_letter('f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, 1)
    expect(XCenter.for_letter('g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, -2)
    expect(XCenter.for_letter('h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, -2)
    expect(XCenter.for_letter('i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, -2)
    expect(XCenter.for_letter('j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 1)
    expect(XCenter.for_letter('k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, -2)
    expect(XCenter.for_letter('l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, 1)
    expect(XCenter.for_letter('m').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 1)
    expect(XCenter.for_letter('n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, 1)
    expect(XCenter.for_letter('o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, -2)
    expect(XCenter.for_letter('p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, -2)
    expect(XCenter.for_letter('q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, -2)
    expect(XCenter.for_letter('r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 1)
    expect(XCenter.for_letter('s').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, -2)
    expect(XCenter.for_letter('t').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, 1)
    expect(XCenter.for_letter('u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 1)
    expect(XCenter.for_letter('v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, 1)
    expect(XCenter.for_letter('w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, -2)
    expect(XCenter.for_letter('x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, -2)
  end
end
