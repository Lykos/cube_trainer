# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/skewb_move'
require 'cube_trainer/core/skewb_notation'
require 'cube_trainer/core/skewb_state'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe Core::SkewbNotation do
  include Core

  let(:color_scheme) { ColorScheme::WCA }
  let(:expected_skewb_state) { color_scheme.solved_skewb_state }
  let(:actual_skewb_state) { color_scheme.solved_skewb_state }

  it 'keep a Sarahs Skewb algorithm as a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L F B' y R L F B' x R B'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::SARAH.algorithm_to_string(parsed_algorithm)).to eq("L F B' y R L F B' x R B'")
  end

  it 'keep a fixed corner Skewb algorithm as a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' y B R L B' x U L'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("R U L' y B R L B' x U L'")
  end

  shared_examples 'notation' do |notation|
    it 'stays the same if we serialize and then parse an algorithm' do
      property_of do
        Rantly { skewb_algorithm }
      end.check do |alg|
        alg_string = notation.algorithm_to_string(alg)
        parsed_alg = parse_skewb_algorithm(alg_string, notation)
        alg.apply_to(expected_skewb_state)
        parsed_alg.apply_to(actual_skewb_state)
        expect(actual_skewb_state).to eq_puzzle_state(expected_skewb_state)
      end
    end

    it 'stays the same if we serialize and then parse a move' do
      property_of do
        Rantly { skewb_move }
      end.check do |move|
        move_string = notation.move_to_string(move)
        parsed_move = parse_skewb_move(move_string, notation)
        Core::Algorithm.move(move).apply_to(expected_skewb_state)
        Core::Algorithm.move(parsed_move).apply_to(actual_skewb_state)
        expect(actual_skewb_state).to eq_puzzle_state(expected_skewb_state)
      end
    end
  end

  it_behaves_like 'notation', Core::SkewbNotation::FIXED_CORNER
  it_behaves_like 'notation', Core::SkewbNotation::SARAH

  it 'transforms a Sarahs Skewb algorithm into a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L F y B' R L F B' x R B'", Core::SkewbNotation::SARAH)
    expect(Core::SkewbNotation::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("R U y L' B R L B' x U L'")
  end

  it 'transforms a fixed corner Skewb algorithm into a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' y B R L B' x U L'", Core::SkewbNotation::FIXED_CORNER)
    expect(Core::SkewbNotation::SARAH.algorithm_to_string(parsed_algorithm)).to eq("L F B' y R L F B' x R B'")
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
