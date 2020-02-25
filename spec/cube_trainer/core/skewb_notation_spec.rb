# frozen_string_literal: true

require 'cube_trainer/core/skewb_move'
require 'cube_trainer/core/skewb_notation'
require 'cube_trainer/core/parser'

describe Core::SkewbNotation do
  include Core

  it 'keep a Sarahs Skewb algorithm as a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' B R L B' U L'", Core::SkewbNotation::SARAH)
    puts parsed_algorithm
    expect(Core::SkewbNotation::SARAH.algorithm_to_string(parsed_algorithm)).to eq('')
  end

  it 'keep a fixed corner Skewb algorithm as a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' B R L B' U L'", Core::SkewbNotation::FIXED_CORNER)
    puts parsed_algorithm
    expect(Core::SkewbNotation::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("R U L' B R L B' U L'")
  end

  it 'transforms a Sarahs Skewb algorithm into a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' B R L B' U L'", Core::SkewbNotation::SARAH)
    puts parsed_algorithm
    expect(Core::SkewbNotation::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq('')
  end

  it 'transforms a fixed corner Skewb algorithm into a Sarahs Skewb algorithm' do
    puts "R U L'"
    parsed_algorithm = parse_skewb_algorithm("R U L'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.algorithm_to_string(parsed_algorithm)).to eq("L F B'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("B'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.move_to_string(parsed_move)).to eq("F'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("U'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.move_to_string(parsed_move)).to eq("B'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("R'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.move_to_string(parsed_move)).to eq("L'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("L'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.move_to_string(parsed_move)).to eq("R'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("F'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::FIXED_CORNER.move_to_string(parsed_move)).to eq("B'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("B'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::FIXED_CORNER.move_to_string(parsed_move)).to eq("U'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("L'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::FIXED_CORNER.move_to_string(parsed_move)).to eq("R'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("R'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::FIXED_CORNER.move_to_string(parsed_move)).to eq("L'")
  end
end
