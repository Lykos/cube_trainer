# frozen_string_literal: true

require 'twisty_puzzles/color_scheme'
require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/parser'
require 'twisty_puzzles/skewb_move'
require 'twisty_puzzles/skewb_notation'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe SkewbNotation do
  

  let(:color_scheme) { ColorScheme::WCA }

  it 'keep a Sarahs Skewb algorithm as a Sarahs Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L F B' y R L F B' x R B'", described_class.sarah)
    expect(described_class.sarah.algorithm_to_string(parsed_algorithm)).to eq("L F B' y R L F B' x R B'")
  end

  it 'keep a Rubiks Skewb algorithm as a Rubiks Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("L r F B' r' y R f L F b B' x R l B'", described_class.rubiks)
    expect(described_class.rubiks.algorithm_to_string(parsed_algorithm)).to eq("L r F B' r' y R f L F b B' x R l B'")
  end

  it 'keep a fixed corner Skewb algorithm as a fixed corner Skewb algorithm' do
    parsed_algorithm = parse_skewb_algorithm("R U L' y B R L B' x U L'", described_class.fixed_corner)
    expect(described_class.fixed_corner.algorithm_to_string(parsed_algorithm)).to eq("R U L' y B R L B' x U L'")
  end

  shared_examples 'notation' do |notation|
    context "when using #{notation.name} notation" do
      it 'stays empty if we serialize and then parse an empty algorithm' do
        alg_string = described_class.fixed_corner.algorithm_to_string(Algorithm::EMPTY)
        parsed_alg = parse_skewb_algorithm(alg_string, notation)
        expect(parsed_alg).to equivalent_skewb_algorithm(Algorithm::EMPTY, color_scheme)
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
  end

  include_examples 'notation', described_class.fixed_corner
  include_examples 'notation', described_class.sarah
  include_examples 'notation', described_class.rubiks

  it 'transforms a Sarahs sledge into a fixed corner sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L'", described_class.sarah)
    expect(described_class.fixed_corner.algorithm_to_string(parsed_algorithm)).to start_with("B' L R L'")
  end

  it 'transforms a Sarahs triple sledge into a fixed corner triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L' F' L F L' F' L F L'", described_class.sarah)
    expect(described_class.fixed_corner.algorithm_to_string(parsed_algorithm)).to eq("B' L R L' B' U L U' B' R U R'")
  end

  it 'transforms a fixed corner triple sledge into a Sarahs triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("B' L R L'", described_class.fixed_corner)
    expect(described_class.sarah.algorithm_to_string(parsed_algorithm)).to start_with("F' L F L'")
  end

  it 'transforms a fixed corner triple sledge into a Sarahs triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("B' L R L' B' U L U' B' R U R'", described_class.fixed_corner)
    expect(described_class.sarah.algorithm_to_string(parsed_algorithm)).to eq("F' L F L' F' L F L' F' L F L'")
  end

  it 'transforms a Sarahs sledge into a Rubiks sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L'", described_class.sarah)
    expect(described_class.rubiks.algorithm_to_string(parsed_algorithm)).to start_with("F' L F L'")
  end

  it 'transforms a Sarahs triple sledge into a Rubiks triple sledge' do
    parsed_algorithm = parse_skewb_algorithm("F' L F L' F' L F L' F' L F L'", described_class.sarah)
    expect(described_class.rubiks.algorithm_to_string(parsed_algorithm)).to eq("F' L F L' F' L F L' F' L F L'")
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

  include_examples 'Skewb notation transformation', described_class.fixed_corner, 'B', described_class.sarah, "F y' x'"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, "B'", described_class.sarah, "F' x y"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, 'U', described_class.sarah, 'B'
  include_examples 'Skewb notation transformation', described_class.fixed_corner, "U'", described_class.sarah, "B'"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, 'R', described_class.sarah, "L x y'"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, "R'", described_class.sarah, "L' y x'"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, 'L', described_class.sarah, "R x' y'"
  include_examples 'Skewb notation transformation', described_class.fixed_corner, "L'", described_class.sarah, "R' y x"

  include_examples 'Skewb notation transformation', described_class.sarah, 'F', described_class.fixed_corner, 'B x y'
  include_examples 'Skewb notation transformation', described_class.sarah, "F'", described_class.fixed_corner, "B' y' x'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'B', described_class.fixed_corner, 'U'
  include_examples 'Skewb notation transformation', described_class.sarah, "B'", described_class.fixed_corner, "U'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'L', described_class.fixed_corner, 'R z y'
  include_examples 'Skewb notation transformation', described_class.sarah, "L'", described_class.fixed_corner, "R' y' z'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'R', described_class.fixed_corner, "L z' y"
  include_examples 'Skewb notation transformation', described_class.sarah, "R'", described_class.fixed_corner, "L' y' z"

  include_examples 'Skewb notation transformation', described_class.sarah, 'F', described_class.rubiks, 'F'
  include_examples 'Skewb notation transformation', described_class.sarah, "F'", described_class.rubiks, "F'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'B', described_class.rubiks, 'B'
  include_examples 'Skewb notation transformation', described_class.sarah, "B'", described_class.rubiks, "B'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'L', described_class.rubiks, 'L'
  include_examples 'Skewb notation transformation', described_class.sarah, "L'", described_class.rubiks, "L'"
  include_examples 'Skewb notation transformation', described_class.sarah, 'R', described_class.rubiks, 'R'
  include_examples 'Skewb notation transformation', described_class.sarah, "R'", described_class.rubiks, "R'"

  include_examples 'Skewb notation transformation', described_class.rubiks, 'F', described_class.sarah, 'F'
  include_examples 'Skewb notation transformation', described_class.rubiks, "F'", described_class.sarah, "F'"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'B', described_class.sarah, 'B'
  include_examples 'Skewb notation transformation', described_class.rubiks, "B'", described_class.sarah, "B'"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'L', described_class.sarah, 'L'
  include_examples 'Skewb notation transformation', described_class.rubiks, "L'", described_class.sarah, "L'"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'R', described_class.sarah, 'R'
  include_examples 'Skewb notation transformation', described_class.rubiks, "R'", described_class.sarah, "R'"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'f', described_class.sarah, "B y' x"
  include_examples 'Skewb notation transformation', described_class.rubiks, "f'", described_class.sarah, "B' x' y"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'b', described_class.sarah, "F y' x'"
  include_examples 'Skewb notation transformation', described_class.rubiks, "b'", described_class.sarah, "F' x y"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'l', described_class.sarah, "R x' y'"
  include_examples 'Skewb notation transformation', described_class.rubiks, "l'", described_class.sarah, "R' y x"
  include_examples 'Skewb notation transformation', described_class.rubiks, 'r', described_class.sarah, "L x y'"
  include_examples 'Skewb notation transformation', described_class.rubiks, "r'", described_class.sarah, "L' y x'"
end
