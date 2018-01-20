require 'cube'

include CubeTrainer

RSpec::Matchers.define :be_rotationally_equivalent_to do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

RSpec::Matchers.define :have_equivalent_coordinates_to do |expected|
  include CoordinateHelper
  match do |actual|
    equivalent_coordinates(actual, expected, cube_size)
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
  
  it 'returns the right index_on_face' do
    expect(Edge.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
    expect(Edge.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
    expect(Edge.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
    expect(Edge.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
    expect(Edge.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
    expect(Edge.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Edge.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Edge.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -1])
    expect(Edge.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 1])
  end
end

describe Midge do
  it_behaves_like 'Part', Midge

  let(:cube_size) { 5 }

  it 'returns the right index_on_face' do
    expect(Midge.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
    expect(Midge.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
    expect(Midge.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
    expect(Midge.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
    expect(Midge.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
    expect(Midge.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Midge.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Midge.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -1])
    expect(Midge.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 2])
  end
end

describe Wing do
  it_behaves_like 'Part', Wing

  let(:cube_size) { 4 }

  it 'should parse wings in UB correctly' do
    expect(Wing.parse('UBl')).to be == Wing.new([:orange, :yellow])
    expect(Wing.parse('UBr')).to be == Wing.new([:yellow, :orange])
    expect(Wing.parse('BUl')).to be == Wing.new([:orange, :yellow])
    expect(Wing.parse('BUr')).to be == Wing.new([:yellow, :orange])
  end

  it 'should parse wings in DB correctly' do
    expect(Wing.parse('DBL')).to be == Wing.new([:white, :orange])
    expect(Wing.parse('DBR')).to be == Wing.new([:orange, :white])
    expect(Wing.parse('BDL')).to be == Wing.new([:white, :orange])
    expect(Wing.parse('BDR')).to be == Wing.new([:orange, :white])
  end

  it 'should parse wings in UF correctly' do
    expect(Wing.parse('UFl')).to be == Wing.new([:yellow, :red])
    expect(Wing.parse('UFr')).to be == Wing.new([:red, :yellow])
    expect(Wing.parse('FUl')).to be == Wing.new([:yellow, :red])
    expect(Wing.parse('FUr')).to be == Wing.new([:red, :yellow])
  end

  it 'should parse wings in DF correctly' do
    expect(Wing.parse('DFl')).to be == Wing.new([:red, :white])
    expect(Wing.parse('DFr')).to be == Wing.new([:white, :red])
    expect(Wing.parse('FDl')).to be == Wing.new([:red, :white])
    expect(Wing.parse('FDr')).to be == Wing.new([:white, :red])
  end

  it 'should parse wings in UR correctly' do
    expect(Wing.parse('URb')).to be == Wing.new([:green, :yellow])
    expect(Wing.parse('URf')).to be == Wing.new([:yellow, :green])
    expect(Wing.parse('RUb')).to be == Wing.new([:green, :yellow])
    expect(Wing.parse('RUf')).to be == Wing.new([:yellow, :green])
  end

  it 'should parse wings in FR correctly' do
    expect(Wing.parse('FRu')).to be == Wing.new([:green, :red])
    expect(Wing.parse('FRd')).to be == Wing.new([:red, :green])
    expect(Wing.parse('RFu')).to be == Wing.new([:green, :red])
    expect(Wing.parse('RFd')).to be == Wing.new([:red, :green])
  end

  it 'returns the right index_on_face' do
    expect(Wing.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Wing.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Wing.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 3])
    expect(Wing.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 1])
    expect(Wing.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Wing.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Wing.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 3])
    expect(Wing.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 2])
    expect(Wing.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Wing.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Wing.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 3])
    expect(Wing.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 1])
    expect(Wing.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Wing.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Wing.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 3])
    expect(Wing.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 2])
    expect(Wing.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 2])
    expect(Wing.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 0])
    expect(Wing.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 3])
    expect(Wing.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 1])
    expect(Wing.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 1])
    expect(Wing.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 0])
    expect(Wing.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 3])
    expect(Wing.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([3, 2])
  end
end

describe Corner do
  it_behaves_like 'Part', Corner

  let(:cube_size) { 3 }

  it 'returns the right index_on_face' do
    expect(Corner.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
    expect(Corner.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
    expect(Corner.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
    expect(Corner.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
    expect(Corner.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
    expect(Corner.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, 0])
    expect(Corner.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, 0])
    expect(Corner.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([0, -1])
    expect(Corner.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-1, -1])
  end
end

describe Face do
  let (:white_face) { Face.new([:white]) }
  let (:yellow_face) { Face.new([:yellow]) }
  let (:red_face) { Face.new([:red]) }
  let (:orange_face) { Face.new([:orange]) }
  let (:green_face) { Face.new([:green]) }
  let (:blue_face) { Face.new([:blue]) }
  
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

  it 'returns the right index_on_face' do
    expect(TCenter.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
    expect(TCenter.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
    expect(TCenter.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
    expect(TCenter.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
    expect(TCenter.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
    expect(TCenter.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 2])
    expect(TCenter.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, 1])
    expect(TCenter.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([2, -2])
    expect(TCenter.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 2])
  end
end

describe XCenter do
  it_behaves_like 'Part', XCenter
  
  let(:cube_size) { 4 }

  it 'returns the right index_on_face' do
    expect(XCenter.for_letter('a').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('b').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('c').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
    expect(XCenter.for_letter('d').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('e').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('f').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('g').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('h').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
    expect(XCenter.for_letter('i').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('j').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('k').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
    expect(XCenter.for_letter('l').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('m').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('n').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('o').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('p').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
    expect(XCenter.for_letter('q').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('r').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('s').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
    expect(XCenter.for_letter('t').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('u').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, 1])
    expect(XCenter.for_letter('v').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, 1])
    expect(XCenter.for_letter('w').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([1, -2])
    expect(XCenter.for_letter('x').index_on_face(cube_size, 0)).to have_equivalent_coordinates_to([-2, -2])
  end
end
