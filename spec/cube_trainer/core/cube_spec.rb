# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_scheme'

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

describe Core::Edge do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::Edge, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Edge, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Edge, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, -1)
    expect(letter_scheme.for_letter(Core::Edge, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 1)
  end
end

describe Core::Midge do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::Midge, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Midge, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Midge, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, -1)
    expect(letter_scheme.for_letter(Core::Midge, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 2)
  end
end

describe Core::Wing do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 4 }

  it 'should parse wings in UB correctly' do
    expect(Core::Wing.parse('UBl')).to be == Core::Wing.for_face_symbols(%i[B U])
    expect(Core::Wing.parse('UBr')).to be == Core::Wing.for_face_symbols(%i[U B])
    expect(Core::Wing.parse('BUl')).to be == Core::Wing.for_face_symbols(%i[B U])
    expect(Core::Wing.parse('BUr')).to be == Core::Wing.for_face_symbols(%i[U B])
  end

  it 'should parse wings in DB correctly' do
    expect(Core::Wing.parse('DBL')).to be == Core::Wing.for_face_symbols(%i[D B])
    expect(Core::Wing.parse('DBR')).to be == Core::Wing.for_face_symbols(%i[B D])
    expect(Core::Wing.parse('BDL')).to be == Core::Wing.for_face_symbols(%i[D B])
    expect(Core::Wing.parse('BDR')).to be == Core::Wing.for_face_symbols(%i[B D])
  end

  it 'should parse wings in UF correctly' do
    expect(Core::Wing.parse('UFl')).to be == Core::Wing.for_face_symbols(%i[U F])
    expect(Core::Wing.parse('UFr')).to be == Core::Wing.for_face_symbols(%i[F U])
    expect(Core::Wing.parse('FUl')).to be == Core::Wing.for_face_symbols(%i[U F])
    expect(Core::Wing.parse('FUr')).to be == Core::Wing.for_face_symbols(%i[F U])
  end

  it 'should parse wings in DF correctly' do
    expect(Core::Wing.parse('DFl')).to be == Core::Wing.for_face_symbols(%i[F D])
    expect(Core::Wing.parse('DFr')).to be == Core::Wing.for_face_symbols(%i[D F])
    expect(Core::Wing.parse('FDl')).to be == Core::Wing.for_face_symbols(%i[F D])
    expect(Core::Wing.parse('FDr')).to be == Core::Wing.for_face_symbols(%i[D F])
  end

  it 'should parse wings in UR correctly' do
    expect(Core::Wing.parse('URb')).to be == Core::Wing.for_face_symbols(%i[R U])
    expect(Core::Wing.parse('URf')).to be == Core::Wing.for_face_symbols(%i[U R])
    expect(Core::Wing.parse('RUb')).to be == Core::Wing.for_face_symbols(%i[R U])
    expect(Core::Wing.parse('RUf')).to be == Core::Wing.for_face_symbols(%i[U R])
  end

  it 'should parse wings in FR correctly' do
    expect(Core::Wing.parse('FRu')).to be == Core::Wing.for_face_symbols(%i[R F])
    expect(Core::Wing.parse('FRd')).to be == Core::Wing.for_face_symbols(%i[F R])
    expect(Core::Wing.parse('RFu')).to be == Core::Wing.for_face_symbols(%i[R F])
    expect(Core::Wing.parse('RFd')).to be == Core::Wing.for_face_symbols(%i[F R])
  end

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::Wing, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Wing, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Wing, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Core::Wing, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Wing, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Core::Wing, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Core::Wing, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Wing, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Wing, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Core::Wing, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Wing, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Core::Wing, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 3, 2)
    expect(letter_scheme.for_letter(Core::Wing, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(Core::Wing, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(Core::Wing, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 3)
    expect(letter_scheme.for_letter(Core::Wing, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 3, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(Core::Wing, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(Core::Wing, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 3)
    expect(letter_scheme.for_letter(Core::Wing, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 3, 2)
  end
end

describe Core::Corner do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::Corner, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, -1)
    expect(letter_scheme.for_letter(Core::Corner, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 0)
    expect(letter_scheme.for_letter(Core::Corner, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, -1)
    expect(letter_scheme.for_letter(Core::Corner, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, -1)
  end
end

describe Core::Face do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }

  it 'should return the right neighbor faces' do
    expect(Core::Face::U.neighbors).to be_rotationally_equivalent_to [Core::Face::R, Core::Face::F, Core::Face::L, Core::Face::B]
    expect(Core::Face::D.neighbors).to be_rotationally_equivalent_to [Core::Face::F, Core::Face::R, Core::Face::B, Core::Face::L]
    expect(Core::Face::F.neighbors).to be_rotationally_equivalent_to [Core::Face::U, Core::Face::R, Core::Face::D, Core::Face::L]
    expect(Core::Face::B.neighbors).to be_rotationally_equivalent_to [Core::Face::R, Core::Face::U, Core::Face::L, Core::Face::D]
    expect(Core::Face::R.neighbors).to be_rotationally_equivalent_to [Core::Face::F, Core::Face::U, Core::Face::B, Core::Face::D]
    expect(Core::Face::L.neighbors).to be_rotationally_equivalent_to [Core::Face::U, Core::Face::F, Core::Face::D, Core::Face::B]
  end

  it 'should return the right piece index' do
    expect(Core::Face::U.piece_index).to be == 0
    expect(Core::Face::F.piece_index).to be == 1
    expect(Core::Face::R.piece_index).to be == 2
    expect(Core::Face::L.piece_index).to be == 3
    expect(Core::Face::B.piece_index).to be == 4
    expect(Core::Face::D.piece_index).to be == 5
  end

  it 'should return the right axis priority' do
    expect(Core::Face::U.axis_priority).to be == 0
    expect(Core::Face::D.axis_priority).to be == 0
    expect(Core::Face::F.axis_priority).to be == 1
    expect(Core::Face::B.axis_priority).to be == 1
    expect(Core::Face::R.axis_priority).to be == 2
    expect(Core::Face::L.axis_priority).to be == 2
  end

  it 'should answer which faces are close to smaller indices' do
    expect(Core::Face::U.close_to_smaller_indices?).to be true
    expect(Core::Face::D.close_to_smaller_indices?).to be false
    expect(Core::Face::F.close_to_smaller_indices?).to be true
    expect(Core::Face::B.close_to_smaller_indices?).to be false
    expect(Core::Face::R.close_to_smaller_indices?).to be true
    expect(Core::Face::L.close_to_smaller_indices?).to be false
  end

  it 'should find out what rotations to do to get to the position of the same face' do
    expect(Core::Face::U.rotation_to(Core::Face::U)).to be == Core::Algorithm.empty
    expect(Core::Face::D.rotation_to(Core::Face::D)).to be == Core::Algorithm.empty
    expect(Core::Face::F.rotation_to(Core::Face::F)).to be == Core::Algorithm.empty
    expect(Core::Face::B.rotation_to(Core::Face::B)).to be == Core::Algorithm.empty
    expect(Core::Face::R.rotation_to(Core::Face::R)).to be == Core::Algorithm.empty
    expect(Core::Face::L.rotation_to(Core::Face::L)).to be == Core::Algorithm.empty
  end

  it 'should find out what rotations to do to get to the position of an opposite face' do
    expect(Core::Face::U.rotation_to(Core::Face::D)).to be_one_of [parse_algorithm('x2'), parse_algorithm('z2')]
    expect(Core::Face::D.rotation_to(Core::Face::U)).to be_one_of [parse_algorithm('x2'), parse_algorithm('z2')]
    expect(Core::Face::F.rotation_to(Core::Face::B)).to be_one_of [parse_algorithm('y2'), parse_algorithm('x2')]
    expect(Core::Face::B.rotation_to(Core::Face::F)).to be_one_of [parse_algorithm('y2'), parse_algorithm('x2')]
    expect(Core::Face::R.rotation_to(Core::Face::L)).to be_one_of [parse_algorithm('y2'), parse_algorithm('z2')]
    expect(Core::Face::L.rotation_to(Core::Face::R)).to be_one_of [parse_algorithm('y2'), parse_algorithm('z2')]
  end

  it 'should find out what rotations to do to get to the position of a neighbor face' do
    expect(Core::Face::U.rotation_to(Core::Face::F)).to be == parse_algorithm("x'")
    expect(Core::Face::U.rotation_to(Core::Face::B)).to be == parse_algorithm('x')
    expect(Core::Face::U.rotation_to(Core::Face::R)).to be == parse_algorithm("z'")
    expect(Core::Face::U.rotation_to(Core::Face::L)).to be == parse_algorithm('z')

    expect(Core::Face::D.rotation_to(Core::Face::F)).to be == parse_algorithm('x')
    expect(Core::Face::D.rotation_to(Core::Face::B)).to be == parse_algorithm("x'")
    expect(Core::Face::D.rotation_to(Core::Face::R)).to be == parse_algorithm('z')
    expect(Core::Face::D.rotation_to(Core::Face::L)).to be == parse_algorithm("z'")

    expect(Core::Face::F.rotation_to(Core::Face::U)).to be == parse_algorithm('x')
    expect(Core::Face::F.rotation_to(Core::Face::D)).to be == parse_algorithm("x'")
    expect(Core::Face::F.rotation_to(Core::Face::R)).to be == parse_algorithm("y'")
    expect(Core::Face::F.rotation_to(Core::Face::L)).to be == parse_algorithm('y')

    expect(Core::Face::B.rotation_to(Core::Face::U)).to be == parse_algorithm("x'")
    expect(Core::Face::B.rotation_to(Core::Face::D)).to be == parse_algorithm('x')
    expect(Core::Face::B.rotation_to(Core::Face::R)).to be == parse_algorithm('y')
    expect(Core::Face::B.rotation_to(Core::Face::L)).to be == parse_algorithm("y'")

    expect(Core::Face::R.rotation_to(Core::Face::U)).to be == parse_algorithm('z')
    expect(Core::Face::R.rotation_to(Core::Face::D)).to be == parse_algorithm("z'")
    expect(Core::Face::R.rotation_to(Core::Face::F)).to be == parse_algorithm('y')
    expect(Core::Face::R.rotation_to(Core::Face::B)).to be == parse_algorithm("y'")

    expect(Core::Face::L.rotation_to(Core::Face::U)).to be == parse_algorithm("z'")
    expect(Core::Face::L.rotation_to(Core::Face::D)).to be == parse_algorithm('z')
    expect(Core::Face::L.rotation_to(Core::Face::F)).to be == parse_algorithm("y'")
    expect(Core::Face::L.rotation_to(Core::Face::B)).to be == parse_algorithm('y')
  end
end

describe Core::TCenter do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::TCenter, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 2)
    expect(letter_scheme.for_letter(Core::TCenter, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 1)
    expect(letter_scheme.for_letter(Core::TCenter, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, -2)
    expect(letter_scheme.for_letter(Core::TCenter, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, 2)
  end
end

describe Core::XCenter do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 4 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(Core::XCenter, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, 1)
    expect(letter_scheme.for_letter(Core::XCenter, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, -2)
    expect(letter_scheme.for_letter(Core::XCenter, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, -2)
  end
end
