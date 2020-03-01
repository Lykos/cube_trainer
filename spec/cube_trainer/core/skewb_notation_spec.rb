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
      expect(parsed_alg).to equivalent_skewb_algorithm(Core::Algorithm::EMPTY, color_scheme)
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
  end

  context 'when using fixed corner notation' do
    include_examples 'notation', described_class::FIXED_CORNER
  end

  context 'when using Sarahs notation' do
    include_examples 'notation', described_class::SARAH
  end

  it 'transforms a Sarahs sledge into a fixed corner sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to start_with("B' L R L'")
  end

  it 'transforms a Sarahs triple sledge into a fixed corner triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L' F' L F L' F' L F L'", described_class::SARAH)
    expect(described_class::FIXED_CORNER.algorithm_to_string(parsed_algorithm)).to eq("B' L R L' B' U L U' B' R U R'")
  end

  it 'transforms a fixed corner triple sledge into a Sarahs triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("B' L R L'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.algorithm_to_string(parsed_algorithm)).to start_with("F' L F L'")
  end

  it 'transforms a fixed corner triple sledge into a Sarahs triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("B' L R L' B' U L U' B' R U R'", described_class::FIXED_CORNER)
    expect(described_class::SARAH.algorithm_to_string(parsed_algorithm)).to eq("F' L F L' F' L F L' F' L F L'")
  end

  shared_examples 'Skewb notation transformation' do |input_notation,
                                                      input_move_string,
                                                      output_notation,
                                                      expected_move_string|

    it "transforms a #{input_notation.name} Skewb move #{input_move_string} into a #{output_notation.name} Skewb move plus potential rotations #{expected_move_string}" do
      parsed_move = parse_skewb_algorithm(input_move_string, input_notation)
      actual_move_string = output_notation.algorithm_to_string(parsed_move)
      actual_move_parts = actual_move_string.split(' ')
      expected_move_parts = expected_move_string.split(' ')

      # We check the actual move for exact equality
      expect(actual_move_parts[0]).to eq(expected_move_parts[0])

      # We check the appended rotations for equivalence
      actual_rotations = parse_skewb_algorithm(actual_move_parts[1..-1].join(' '), output_notation)
      expected_rotations = parse_skewb_algorithm(expected_move_parts[1..-1].join(' '), output_notation)
      expect(actual_rotations).to equivalent_skewb_algorithm(expected_rotations, color_scheme)
    end
  end

  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, 'B', described_class::SARAH, "F y' x'"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "B'", described_class::SARAH, "F' x y"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, 'U', described_class::SARAH, "B"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "U'", described_class::SARAH, "B'"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "R", described_class::SARAH, "L x y'"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "R'", described_class::SARAH, "L' y x'"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "L", described_class::SARAH, "R x' y'"
  include_examples 'Skewb notation transformation', described_class::FIXED_CORNER, "L'", described_class::SARAH, "R' y x"
  include_examples 'Skewb notation transformation', described_class::SARAH, "F", described_class::FIXED_CORNER, "B x y"
  include_examples 'Skewb notation transformation', described_class::SARAH, "F'", described_class::FIXED_CORNER, "B' y' x'"
  include_examples 'Skewb notation transformation', described_class::SARAH, "B", described_class::FIXED_CORNER, "U"
  include_examples 'Skewb notation transformation', described_class::SARAH, "B'", described_class::FIXED_CORNER, "U'"
  include_examples 'Skewb notation transformation', described_class::SARAH, "L", described_class::FIXED_CORNER, "R z y"
  include_examples 'Skewb notation transformation', described_class::SARAH, "L'", described_class::FIXED_CORNER, "R' y' z'"
  include_examples 'Skewb notation transformation', described_class::SARAH, "R", described_class::FIXED_CORNER, "L z' y"
  include_examples 'Skewb notation transformation', described_class::SARAH, "R'", described_class::FIXED_CORNER, "L' y' z"
end
