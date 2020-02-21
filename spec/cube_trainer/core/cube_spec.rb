# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_scheme'

RSpec::Matchers.define(:be_rotationally_equivalent_to) do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

RSpec::Matchers.define(:be_one_of) do |expected|
  match do |actual|
    expected.include?(actual)
  end
end

describe Core::Edge do
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 1)
  end
end

describe Core::Midge do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 2)
  end
end

describe Core::Wing do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 4 }

  it 'parses wings in UB correctly' do
    expect(described_class.parse('UBl')).to be == described_class.for_face_symbols(%i[B U])
    expect(described_class.parse('UBr')).to be == described_class.for_face_symbols(%i[U B])
    expect(described_class.parse('BUl')).to be == described_class.for_face_symbols(%i[B U])
    expect(described_class.parse('BUr')).to be == described_class.for_face_symbols(%i[U B])
  end

  it 'parses wings in DB correctly' do
    expect(described_class.parse('DBL')).to be == described_class.for_face_symbols(%i[D B])
    expect(described_class.parse('DBR')).to be == described_class.for_face_symbols(%i[B D])
    expect(described_class.parse('BDL')).to be == described_class.for_face_symbols(%i[D B])
    expect(described_class.parse('BDR')).to be == described_class.for_face_symbols(%i[B D])
  end

  it 'parses wings in UF correctly' do
    expect(described_class.parse('UFl')).to be == described_class.for_face_symbols(%i[U F])
    expect(described_class.parse('UFr')).to be == described_class.for_face_symbols(%i[F U])
    expect(described_class.parse('FUl')).to be == described_class.for_face_symbols(%i[U F])
    expect(described_class.parse('FUr')).to be == described_class.for_face_symbols(%i[F U])
  end

  it 'parses wings in DF correctly' do
    expect(described_class.parse('DFl')).to be == described_class.for_face_symbols(%i[F D])
    expect(described_class.parse('DFr')).to be == described_class.for_face_symbols(%i[D F])
    expect(described_class.parse('FDl')).to be == described_class.for_face_symbols(%i[F D])
    expect(described_class.parse('FDr')).to be == described_class.for_face_symbols(%i[D F])
  end

  it 'parses wings in UR correctly' do
    expect(described_class.parse('URb')).to be == described_class.for_face_symbols(%i[R U])
    expect(described_class.parse('URf')).to be == described_class.for_face_symbols(%i[U R])
    expect(described_class.parse('RUb')).to be == described_class.for_face_symbols(%i[R U])
    expect(described_class.parse('RUf')).to be == described_class.for_face_symbols(%i[U R])
  end

  it 'parses wings in FR correctly' do
    expect(described_class.parse('FRu')).to be == described_class.for_face_symbols(%i[R F])
    expect(described_class.parse('FRd')).to be == described_class.for_face_symbols(%i[F R])
    expect(described_class.parse('RFu')).to be == described_class.for_face_symbols(%i[R F])
    expect(described_class.parse('RFd')).to be == described_class.for_face_symbols(%i[F R])
  end

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 3, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 3, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 3, 2)
  end
end

describe Core::Corner do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -1, -1)
  end
end

describe Core::Face do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }

  it 'returns the right neighbor faces' do
    expect(Core::Face::U.neighbors).to be_rotationally_equivalent_to([Core::Face::R, Core::Face::F, Core::Face::L, Core::Face::B])
    expect(Core::Face::D.neighbors).to be_rotationally_equivalent_to([Core::Face::F, Core::Face::R, Core::Face::B, Core::Face::L])
    expect(Core::Face::F.neighbors).to be_rotationally_equivalent_to([Core::Face::U, Core::Face::R, Core::Face::D, Core::Face::L])
    expect(Core::Face::B.neighbors).to be_rotationally_equivalent_to([Core::Face::R, Core::Face::U, Core::Face::L, Core::Face::D])
    expect(Core::Face::R.neighbors).to be_rotationally_equivalent_to([Core::Face::F, Core::Face::U, Core::Face::B, Core::Face::D])
    expect(Core::Face::L.neighbors).to be_rotationally_equivalent_to([Core::Face::U, Core::Face::F, Core::Face::D, Core::Face::B])
  end

  it 'returns the right piece index' do
    expect(Core::Face::U.piece_index).to be == 0
    expect(Core::Face::F.piece_index).to be == 1
    expect(Core::Face::R.piece_index).to be == 2
    expect(Core::Face::L.piece_index).to be == 3
    expect(Core::Face::B.piece_index).to be == 4
    expect(Core::Face::D.piece_index).to be == 5
  end

  it 'returns the right axis priority' do
    expect(Core::Face::U.axis_priority).to be == 0
    expect(Core::Face::D.axis_priority).to be == 0
    expect(Core::Face::F.axis_priority).to be == 1
    expect(Core::Face::B.axis_priority).to be == 1
    expect(Core::Face::R.axis_priority).to be == 2
    expect(Core::Face::L.axis_priority).to be == 2
  end

  it 'answers which faces are close to smaller indices' do
    expect(Core::Face::U.close_to_smaller_indices?).to be(true)
    expect(Core::Face::D.close_to_smaller_indices?).to be(false)
    expect(Core::Face::F.close_to_smaller_indices?).to be(true)
    expect(Core::Face::B.close_to_smaller_indices?).to be(false)
    expect(Core::Face::R.close_to_smaller_indices?).to be(true)
    expect(Core::Face::L.close_to_smaller_indices?).to be(false)
  end

  it 'finds out what rotations to do to get to the position of the same face' do
    expect(Core::Face::U.rotation_to(Core::Face::U)).to be == Core::Algorithm::EMPTY
    expect(Core::Face::D.rotation_to(Core::Face::D)).to be == Core::Algorithm::EMPTY
    expect(Core::Face::F.rotation_to(Core::Face::F)).to be == Core::Algorithm::EMPTY
    expect(Core::Face::B.rotation_to(Core::Face::B)).to be == Core::Algorithm::EMPTY
    expect(Core::Face::R.rotation_to(Core::Face::R)).to be == Core::Algorithm::EMPTY
    expect(Core::Face::L.rotation_to(Core::Face::L)).to be == Core::Algorithm::EMPTY
  end

  it 'finds out what rotations to do to get to the position of an opposite face' do
    expect(Core::Face::U.rotation_to(Core::Face::D)).to be_one_of([parse_algorithm('x2'), parse_algorithm('z2')])
    expect(Core::Face::D.rotation_to(Core::Face::U)).to be_one_of([parse_algorithm('x2'), parse_algorithm('z2')])
    expect(Core::Face::F.rotation_to(Core::Face::B)).to be_one_of([parse_algorithm('y2'), parse_algorithm('x2')])
    expect(Core::Face::B.rotation_to(Core::Face::F)).to be_one_of([parse_algorithm('y2'), parse_algorithm('x2')])
    expect(Core::Face::R.rotation_to(Core::Face::L)).to be_one_of([parse_algorithm('y2'), parse_algorithm('z2')])
    expect(Core::Face::L.rotation_to(Core::Face::R)).to be_one_of([parse_algorithm('y2'), parse_algorithm('z2')])
  end

  it 'finds out what rotations to do to get to the position of a neighbor face' do
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
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, 2)
  end
end

describe Core::XCenter do
  include Core

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:cube_size) { 4 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::U, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::F, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::R, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::L, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::B, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to be == Core::Coordinate.from_indices(Core::Face::D, cube_size, -2, -2)
  end
end
