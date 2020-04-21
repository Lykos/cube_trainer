# frozen_string_literal: true

require 'twisty_puzzles/cube'
require 'twisty_puzzles/coordinate'
require 'twisty_puzzles/parser'
require 'twisty_puzzles/letter_scheme'

RSpec::Matchers.define(:be_rotationally_equivalent_to) do |expected|
  match do |actual|
    expected.length == actual.length && (0...expected.length).any? { |i| actual.rotate(i) == expected }
  end
end

RSpec::Matchers.define(:be_one_of) do |*expected|
  match do |actual|
    expected.include?(actual)
  end
end

describe Edge do
  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -1, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -1, 1)
  end
end

describe Midge do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -1, 2)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 2, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -1, 2)
  end
end

describe Wing do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 4 }

  it 'parses wings in UB correctly' do
    expect(described_class.parse('UBl')).to eq(described_class.for_face_symbols(%i[B U]))
    expect(described_class.parse('UBr')).to eq(described_class.for_face_symbols(%i[U B]))
    expect(described_class.parse('BUl')).to eq(described_class.for_face_symbols(%i[B U]))
    expect(described_class.parse('BUr')).to eq(described_class.for_face_symbols(%i[U B]))
  end

  it 'parses wings in DB correctly' do
    expect(described_class.parse('DBL')).to eq(described_class.for_face_symbols(%i[D B]))
    expect(described_class.parse('DBR')).to eq(described_class.for_face_symbols(%i[B D]))
    expect(described_class.parse('BDL')).to eq(described_class.for_face_symbols(%i[D B]))
    expect(described_class.parse('BDR')).to eq(described_class.for_face_symbols(%i[B D]))
  end

  it 'parses wings in UF correctly' do
    expect(described_class.parse('UFl')).to eq(described_class.for_face_symbols(%i[U F]))
    expect(described_class.parse('UFr')).to eq(described_class.for_face_symbols(%i[F U]))
    expect(described_class.parse('FUl')).to eq(described_class.for_face_symbols(%i[U F]))
    expect(described_class.parse('FUr')).to eq(described_class.for_face_symbols(%i[F U]))
  end

  it 'parses wings in DF correctly' do
    expect(described_class.parse('DFl')).to eq(described_class.for_face_symbols(%i[F D]))
    expect(described_class.parse('DFr')).to eq(described_class.for_face_symbols(%i[D F]))
    expect(described_class.parse('FDl')).to eq(described_class.for_face_symbols(%i[F D]))
    expect(described_class.parse('FDr')).to eq(described_class.for_face_symbols(%i[D F]))
  end

  it 'parses wings in UR correctly' do
    expect(described_class.parse('URb')).to eq(described_class.for_face_symbols(%i[R U]))
    expect(described_class.parse('URf')).to eq(described_class.for_face_symbols(%i[U R]))
    expect(described_class.parse('RUb')).to eq(described_class.for_face_symbols(%i[R U]))
    expect(described_class.parse('RUf')).to eq(described_class.for_face_symbols(%i[U R]))
  end

  it 'parses wings in FR correctly' do
    expect(described_class.parse('FRu')).to eq(described_class.for_face_symbols(%i[R F]))
    expect(described_class.parse('FRd')).to eq(described_class.for_face_symbols(%i[F R]))
    expect(described_class.parse('RFu')).to eq(described_class.for_face_symbols(%i[R F]))
    expect(described_class.parse('RFd')).to eq(described_class.for_face_symbols(%i[F R]))
  end

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 3, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 3, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 0, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 2, 3)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 3, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 0, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 2, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, 3)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 3, 2)
  end
end

describe Corner do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 3 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -1, -1)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 0, 0)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -1, 0)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 0, -1)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -1, -1)
  end
end

describe Face do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }

  it 'returns the right neighbor faces' do
    expect(Face::U.neighbors).to be_rotationally_equivalent_to([Face::R, Face::F, Face::L, Face::B])
    expect(Face::D.neighbors).to be_rotationally_equivalent_to([Face::F, Face::R, Face::B, Face::L])
    expect(Face::F.neighbors).to be_rotationally_equivalent_to([Face::U, Face::R, Face::D, Face::L])
    expect(Face::B.neighbors).to be_rotationally_equivalent_to([Face::R, Face::U, Face::L, Face::D])
    expect(Face::R.neighbors).to be_rotationally_equivalent_to([Face::F, Face::U, Face::B, Face::D])
    expect(Face::L.neighbors).to be_rotationally_equivalent_to([Face::U, Face::F, Face::D, Face::B])
  end

  it 'returns the right piece index' do
    expect(Face::U.piece_index).to eq(0)
    expect(Face::F.piece_index).to eq(1)
    expect(Face::R.piece_index).to eq(2)
    expect(Face::L.piece_index).to eq(3)
    expect(Face::B.piece_index).to eq(4)
    expect(Face::D.piece_index).to eq(5)
  end

  it 'returns the right axis priority' do
    expect(Face::U.axis_priority).to eq(0)
    expect(Face::D.axis_priority).to eq(0)
    expect(Face::F.axis_priority).to eq(1)
    expect(Face::B.axis_priority).to eq(1)
    expect(Face::R.axis_priority).to eq(2)
    expect(Face::L.axis_priority).to eq(2)
  end

  it 'answers which faces are close to smaller indices' do
    expect(Face::U.close_to_smaller_indices?).to be(true)
    expect(Face::D.close_to_smaller_indices?).to be(false)
    expect(Face::F.close_to_smaller_indices?).to be(true)
    expect(Face::B.close_to_smaller_indices?).to be(false)
    expect(Face::R.close_to_smaller_indices?).to be(true)
    expect(Face::L.close_to_smaller_indices?).to be(false)
  end

  it 'finds out what rotations to do to get to the position of the same face' do
    expect(Face::U.rotation_to(Face::U)).to eq(Algorithm::EMPTY)
    expect(Face::D.rotation_to(Face::D)).to eq(Algorithm::EMPTY)
    expect(Face::F.rotation_to(Face::F)).to eq(Algorithm::EMPTY)
    expect(Face::B.rotation_to(Face::B)).to eq(Algorithm::EMPTY)
    expect(Face::R.rotation_to(Face::R)).to eq(Algorithm::EMPTY)
    expect(Face::L.rotation_to(Face::L)).to eq(Algorithm::EMPTY)
  end

  it 'finds out what rotations to do to get to the position of an opposite face' do
    expect(Face::U.rotation_to(Face::D)).to be_one_of(parse_algorithm('x2'), parse_algorithm('z2'))
    expect(Face::D.rotation_to(Face::U)).to be_one_of(parse_algorithm('x2'), parse_algorithm('z2'))
    expect(Face::F.rotation_to(Face::B)).to be_one_of(parse_algorithm('y2'), parse_algorithm('x2'))
    expect(Face::B.rotation_to(Face::F)).to be_one_of(parse_algorithm('y2'), parse_algorithm('x2'))
    expect(Face::R.rotation_to(Face::L)).to be_one_of(parse_algorithm('y2'), parse_algorithm('z2'))
    expect(Face::L.rotation_to(Face::R)).to be_one_of(parse_algorithm('y2'), parse_algorithm('z2'))
  end

  it 'finds out what rotations to do to get to the position of a neighbor face' do
    expect(Face::U.rotation_to(Face::F)).to eq_cube_algorithm("x'")
    expect(Face::U.rotation_to(Face::B)).to eq_cube_algorithm('x')
    expect(Face::U.rotation_to(Face::R)).to eq_cube_algorithm("z'")
    expect(Face::U.rotation_to(Face::L)).to eq_cube_algorithm('z')

    expect(Face::D.rotation_to(Face::F)).to eq_cube_algorithm('x')
    expect(Face::D.rotation_to(Face::B)).to eq_cube_algorithm("x'")
    expect(Face::D.rotation_to(Face::R)).to eq_cube_algorithm('z')
    expect(Face::D.rotation_to(Face::L)).to eq_cube_algorithm("z'")

    expect(Face::F.rotation_to(Face::U)).to eq_cube_algorithm('x')
    expect(Face::F.rotation_to(Face::D)).to eq_cube_algorithm("x'")
    expect(Face::F.rotation_to(Face::R)).to eq_cube_algorithm("y'")
    expect(Face::F.rotation_to(Face::L)).to eq_cube_algorithm('y')

    expect(Face::B.rotation_to(Face::U)).to eq_cube_algorithm("x'")
    expect(Face::B.rotation_to(Face::D)).to eq_cube_algorithm('x')
    expect(Face::B.rotation_to(Face::R)).to eq_cube_algorithm('y')
    expect(Face::B.rotation_to(Face::L)).to eq_cube_algorithm("y'")

    expect(Face::R.rotation_to(Face::U)).to eq_cube_algorithm('z')
    expect(Face::R.rotation_to(Face::D)).to eq_cube_algorithm("z'")
    expect(Face::R.rotation_to(Face::F)).to eq_cube_algorithm('y')
    expect(Face::R.rotation_to(Face::B)).to eq_cube_algorithm("y'")

    expect(Face::L.rotation_to(Face::U)).to eq_cube_algorithm("z'")
    expect(Face::L.rotation_to(Face::D)).to eq_cube_algorithm('z')
    expect(Face::L.rotation_to(Face::F)).to eq_cube_algorithm("y'")
    expect(Face::L.rotation_to(Face::B)).to eq_cube_algorithm('y')
  end
end

describe TCenter do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 5 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -2, 2)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, 2)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 2, 1)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 2, -2)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -2, 2)
  end
end

describe XCenter do
  

  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:cube_size) { 4 }

  it 'returns the right solved_coordinate' do
    expect(letter_scheme.for_letter(described_class, 'a').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'b').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'c').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'd').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::U, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'e').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'f').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'g').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'h').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::F, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'i').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'j').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'k').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'l').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::R, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'm').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'n').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'o').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'p').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::L, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 'q').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'r').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 's').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -2, -2)
    expect(letter_scheme.for_letter(described_class, 't').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::B, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'u').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, 1)
    expect(letter_scheme.for_letter(described_class, 'v').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -2, 1)
    expect(letter_scheme.for_letter(described_class, 'w').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, 1, -2)
    expect(letter_scheme.for_letter(described_class, 'x').solved_coordinate(cube_size, 0)).to eq_cube_coordinate(Face::D, cube_size, -2, -2)
  end
end
