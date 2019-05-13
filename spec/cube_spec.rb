require 'cube'
require 'coordinate'
require 'letter_scheme'

include CubeTrainer

RSpec::Matchers.define :be_rotationally_equivalent_to do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

describe Edge do
  let(:letter_scheme) { DefaultLetterScheme.new }
  let(:cube_size) { 3 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }
    
  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Edge, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 1)
  end
end

describe Midge do
  let(:letter_scheme) { DefaultLetterScheme.new }
  let(:cube_size) { 5 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Midge, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 2)
  end
end

describe Wing do
  let(:letter_scheme) { DefaultLetterScheme.new }
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
    expect(letter_scheme.for_letter(Wing, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Wing, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Wing, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 3, 2)
  end
end

describe Corner do
  let(:letter_scheme) { DefaultLetterScheme.new }
  let(:cube_size) { 3 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Corner, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -1, -1)
  end
end

describe Face do
  let(:letter_scheme) { DefaultLetterScheme.new }
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
  let(:letter_scheme) { DefaultLetterScheme.new }
  let(:cube_size) { 5 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(TCenter, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, 2)
  end
end

describe XCenter do
  let(:letter_scheme) { DefaultLetterScheme.new }  
  let(:cube_size) { 4 }
  let(:white_face) { Face.for_color(:white) }
  let(:yellow_face) { Face.for_color(:yellow) }
  let(:red_face) { Face.for_color(:red) }
  let(:orange_face) { Face.for_color(:orange) }
  let(:green_face) { Face.for_color(:green) }
  let(:blue_face) { Face.for_color(:blue) }
  
  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(XCenter, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.new(yellow_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.new(red_face, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.new(green_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.new(blue_face, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.new(orange_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.new(white_face, cube_size, -2, -2)
  end
end
