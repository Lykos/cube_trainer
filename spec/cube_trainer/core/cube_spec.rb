require 'cube_trainer/core/cube'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_scheme'

include CubeTrainer

RSpec::Matchers.define :be_rotationally_equivalent_to do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

RSpec::Matchers.define :be_one_of do |expected|
  match do |actual|
    expected.include?(actual)
  end
end

describe Edge do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }
    
  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Edge, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Edge, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Edge, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Edge, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Edge, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -1, 1)
  end
end

describe Midge do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Midge, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Midge, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Midge, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Midge, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Midge, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -1, 2)
  end
end

describe Wing do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 4 }

  it 'should parse wings in UB correctly' do
    expect(Wing.parse('UBl')).to be == Wing.for_face_symbols([:B, :U])
    expect(Wing.parse('UBr')).to be == Wing.for_face_symbols([:U, :B])
    expect(Wing.parse('BUl')).to be == Wing.for_face_symbols([:B, :U])
    expect(Wing.parse('BUr')).to be == Wing.for_face_symbols([:U, :B])
  end

  it 'should parse wings in DB correctly' do
    expect(Wing.parse('DBL')).to be == Wing.for_face_symbols([:D, :B])
    expect(Wing.parse('DBR')).to be == Wing.for_face_symbols([:B, :D])
    expect(Wing.parse('BDL')).to be == Wing.for_face_symbols([:D, :B])
    expect(Wing.parse('BDR')).to be == Wing.for_face_symbols([:B, :D])
  end

  it 'should parse wings in UF correctly' do
    expect(Wing.parse('UFl')).to be == Wing.for_face_symbols([:U, :F])
    expect(Wing.parse('UFr')).to be == Wing.for_face_symbols([:F, :U])
    expect(Wing.parse('FUl')).to be == Wing.for_face_symbols([:U, :F])
    expect(Wing.parse('FUr')).to be == Wing.for_face_symbols([:F, :U])
  end

  it 'should parse wings in DF correctly' do
    expect(Wing.parse('DFl')).to be == Wing.for_face_symbols([:F, :D])
    expect(Wing.parse('DFr')).to be == Wing.for_face_symbols([:D, :F])
    expect(Wing.parse('FDl')).to be == Wing.for_face_symbols([:F, :D])
    expect(Wing.parse('FDr')).to be == Wing.for_face_symbols([:D, :F])
  end

  it 'should parse wings in UR correctly' do
    expect(Wing.parse('URb')).to be == Wing.for_face_symbols([:R, :U])
    expect(Wing.parse('URf')).to be == Wing.for_face_symbols([:U, :R])
    expect(Wing.parse('RUb')).to be == Wing.for_face_symbols([:R, :U])
    expect(Wing.parse('RUf')).to be == Wing.for_face_symbols([:U, :R])
  end

  it 'should parse wings in FR correctly' do
    expect(Wing.parse('FRu')).to be == Wing.for_face_symbols([:R, :F])
    expect(Wing.parse('FRd')).to be == Wing.for_face_symbols([:F, :R])
    expect(Wing.parse('RFu')).to be == Wing.for_face_symbols([:R, :F])
    expect(Wing.parse('RFd')).to be == Wing.for_face_symbols([:F, :R])
  end

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Wing, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Wing, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Wing, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Wing, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Wing, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Wing, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Wing, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Wing, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Wing, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Wing, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 3, 2)
  end
end

describe Corner do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Corner, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Corner, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Corner, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Corner, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Corner, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -1, -1)
  end
end

describe Face do
  let(:letter_scheme) { BernhardLetterScheme.new }

  it 'should return the right neighbor faces' do  
    expect(Face::U.neighbors).to be_rotationally_equivalent_to [Face::R, Face::F, Face::L, Face::B]
    expect(Face::D.neighbors).to be_rotationally_equivalent_to [Face::F, Face::R, Face::B, Face::L]
    expect(Face::F.neighbors).to be_rotationally_equivalent_to [Face::U, Face::R, Face::D, Face::L]
    expect(Face::B.neighbors).to be_rotationally_equivalent_to [Face::R, Face::U, Face::L, Face::D]
    expect(Face::R.neighbors).to be_rotationally_equivalent_to [Face::F, Face::U, Face::B, Face::D]
    expect(Face::L.neighbors).to be_rotationally_equivalent_to [Face::U, Face::F, Face::D, Face::B]
  end

  it 'should return the right piece index' do
    expect(Face::U.piece_index).to be == 0
    expect(Face::F.piece_index).to be == 1
    expect(Face::R.piece_index).to be == 2
    expect(Face::L.piece_index).to be == 3
    expect(Face::B.piece_index).to be == 4
    expect(Face::D.piece_index).to be == 5
  end

  it 'should return the right axis priority' do
    expect(Face::U.axis_priority).to be == 0
    expect(Face::D.axis_priority).to be == 0
    expect(Face::F.axis_priority).to be == 1
    expect(Face::B.axis_priority).to be == 1
    expect(Face::R.axis_priority).to be == 2
    expect(Face::L.axis_priority).to be == 2
  end

  it 'should answer which faces are close to smaller indices' do
    expect(Face::U.close_to_smaller_indices?).to be true
    expect(Face::D.close_to_smaller_indices?).to be false
    expect(Face::F.close_to_smaller_indices?).to be true
    expect(Face::B.close_to_smaller_indices?).to be false
    expect(Face::R.close_to_smaller_indices?).to be true
    expect(Face::L.close_to_smaller_indices?).to be false
  end

  it 'should find out what rotations to do to get to the position of the same face' do
    expect(Face::U.rotation_to(Face::U)).to be == Algorithm.empty
    expect(Face::D.rotation_to(Face::D)).to be == Algorithm.empty
    expect(Face::F.rotation_to(Face::F)).to be == Algorithm.empty
    expect(Face::B.rotation_to(Face::B)).to be == Algorithm.empty
    expect(Face::R.rotation_to(Face::R)).to be == Algorithm.empty
    expect(Face::L.rotation_to(Face::L)).to be == Algorithm.empty
  end

  it 'should find out what rotations to do to get to the position of an opposite face' do
    expect(Face::U.rotation_to(Face::D)).to be_one_of [parse_algorithm('x2'), parse_algorithm('z2')]
    expect(Face::D.rotation_to(Face::U)).to be_one_of [parse_algorithm('x2'), parse_algorithm('z2')]
    expect(Face::F.rotation_to(Face::B)).to be_one_of [parse_algorithm('y2'), parse_algorithm('x2')]
    expect(Face::B.rotation_to(Face::F)).to be_one_of [parse_algorithm('y2'), parse_algorithm('x2')]
    expect(Face::R.rotation_to(Face::L)).to be_one_of [parse_algorithm('y2'), parse_algorithm('z2')]
    expect(Face::L.rotation_to(Face::R)).to be_one_of [parse_algorithm('y2'), parse_algorithm('z2')]
  end
  
  it 'should find out what rotations to do to get to the position of a neighbor face' do
    expect(Face::U.rotation_to(Face::F)).to be == parse_algorithm("x'")
    expect(Face::U.rotation_to(Face::B)).to be == parse_algorithm("x")
    expect(Face::U.rotation_to(Face::R)).to be == parse_algorithm("z'")
    expect(Face::U.rotation_to(Face::L)).to be == parse_algorithm("z")

    expect(Face::D.rotation_to(Face::F)).to be == parse_algorithm("x")
    expect(Face::D.rotation_to(Face::B)).to be == parse_algorithm("x'")
    expect(Face::D.rotation_to(Face::R)).to be == parse_algorithm("z")
    expect(Face::D.rotation_to(Face::L)).to be == parse_algorithm("z'")

    expect(Face::F.rotation_to(Face::U)).to be == parse_algorithm("x")
    expect(Face::F.rotation_to(Face::D)).to be == parse_algorithm("x'")
    expect(Face::F.rotation_to(Face::R)).to be == parse_algorithm("y'")
    expect(Face::F.rotation_to(Face::L)).to be == parse_algorithm("y")

    expect(Face::B.rotation_to(Face::U)).to be == parse_algorithm("x'")
    expect(Face::B.rotation_to(Face::D)).to be == parse_algorithm("x")
    expect(Face::B.rotation_to(Face::R)).to be == parse_algorithm("y")
    expect(Face::B.rotation_to(Face::L)).to be == parse_algorithm("y'")

    expect(Face::R.rotation_to(Face::U)).to be == parse_algorithm("z")
    expect(Face::R.rotation_to(Face::D)).to be == parse_algorithm("z'")
    expect(Face::R.rotation_to(Face::F)).to be == parse_algorithm("y")
    expect(Face::R.rotation_to(Face::B)).to be == parse_algorithm("y'")
    
    expect(Face::L.rotation_to(Face::U)).to be == parse_algorithm("z'")
    expect(Face::L.rotation_to(Face::D)).to be == parse_algorithm("z")
    expect(Face::L.rotation_to(Face::F)).to be == parse_algorithm("y'")
    expect(Face::L.rotation_to(Face::B)).to be == parse_algorithm("y")
  end

end

describe TCenter do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(TCenter, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -2, 2)
    expect(letter_scheme.for_letter(TCenter, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, 2)
    expect(letter_scheme.for_letter(TCenter, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 2, 1)
    expect(letter_scheme.for_letter(TCenter, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 2, -2)
    expect(letter_scheme.for_letter(TCenter, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -2, 2)
  end
end

describe XCenter do
  let(:letter_scheme) { BernhardLetterScheme.new }  
  let(:cube_size) { 4 }
  
  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(XCenter, 'a').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'b').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'c').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'd').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::U, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'e').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'f').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'g').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'h').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::F, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'i').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'j').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'k').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'l').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::R, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'm').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'n').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'o').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'p').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::L, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 'q').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'r').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 's').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -2, -2)
    expect(letter_scheme.for_letter(XCenter, 't').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::B, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'u').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, 1)
    expect(letter_scheme.for_letter(XCenter, 'v').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -2, 1)
    expect(letter_scheme.for_letter(XCenter, 'w').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, 1, -2)
    expect(letter_scheme.for_letter(XCenter, 'x').solved_coordinate(cube_size, 0)).to be == Coordinate.from_indices(Face::D, cube_size, -2, -2)
  end
end
