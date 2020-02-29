# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/skewb_move'
require 'cube_trainer/core/skewb_notation'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe Core::SkewbNotation do
  include Core

  let(:color_scheme) { ColorScheme::WCA }

  it 'keep a Sarahs Skewb algorithm as a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L F B' y R L F B' x R B'", described_class::SARAH)
    expect(described_class::SARAH.algorithm_to_string(parsed_algorithm)).to eq("L F B' y R L F B' x R B'")
  end

  it 'keep a fixed corner Skewb algorithm as a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' y B R L B' x U L'", described_class::FIXED_CORNER)
    expect(described_class::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("R U L' y B R L B' x U L'")
  end

  shared_examples 'notation' do |notation|
    it 'stays empty if we serialize and then parse an empty algorithm' do
      alg_string = described_class::FIXED_CORNER.algorithm_to_string(Core::Algorithm::EMPTY)
      parsed_alg = parse_skewb_algorithm(alg_string, notation)
      expect(parsed_alg).to equivalent_skewb_algorithm(Core::Algortihm::EMPTY, color_scheme)
    end

    it 'stays the same if we serialize and then parse an algorithm' do
      property_of do
        Rantly { skewb_algorithm }
      end.check do |alg|
        alg_string = notation.algorithm_to_string(alg)
        parsed_alg = parse_skewb_algorithm(alg_string, notation)
        expect(parsed_alg).to equivalent_skewb_algorithm(alg, color_scheme)
      end
    end

    it 'stays the same if we serialize and then parse a move' do
      property_of do
        Rantly { skewb_move }
      end.check do |move|
        move_string = notation.move_to_string(move)
        parsed_move = parse_skewb_move(move_string, notation)
        expect(Core::Algorithm.move(parsed_move)).to equivalent_skewb_algorithm(Core::Algorithm.move(move), color_scheme)
      end
    end
  end

  context 'when using fixed corner notation' do
    it_behaves_like 'notation', described_class::FIXED_CORNER
  end

  context 'when using Sarahs notation' do
    it_behaves_like 'notation', described_class::SARAH
  end

  it 'transforms a Sarahs Skewb algorithm into a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L F y B' R L F B' x R B'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("R U y L' B R L B' x U L'")
  end

  it 'transforms a fixed corner Skewb algorithm into a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' y B R L B' x U L'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.algorithm_to_string(parsed_algorithm)).to eq("L F B' y R L F B' x R B'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("B'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.move_to_string(parsed_move)).to eq("F'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("U'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.move_to_string(parsed_move)).to eq("B'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("R'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.move_to_string(parsed_move)).to eq("L'")
  end

  it 'transforms a fixed corner Skewb move into a Sarahs Skewb move' do
    parsed_move = parse_skewb_move("L'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.move_to_string(parsed_move)).to eq("R'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("F'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.move_to_string(parsed_move)).to eq("B'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("B'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.move_to_string(parsed_move)).to eq("U'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("L'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.move_to_string(parsed_move)).to eq("R'")
  end

  it 'transforms a Sarahs Skewb move into a fixed corner Skewb move' do
    parsed_move = parse_skewb_move("R'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.move_to_string(parsed_move)).to eq("L'")
  end
end
