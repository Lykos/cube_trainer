# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/rotation'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/parser'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe Core::Rotation do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }

  shared_examples 'corner rotations' do |face_symbols, expected_rotation_algorithm|
    let(:actual_rotation_algorithm) do
      Core::Rotation.around_corner(Core::Corner.for_face_symbols(face_symbols), Core::SkewbDirection::FORWARD)
    end

    it 'rotates correctly around cube corners' do
      expect(actual_rotation_algorithm).to equivalent_cube_algorithm(expected_rotation_algorithm, 3, color_scheme)
    end

    it 'rotates correctly around skewb corners' do
      expect(actual_rotation_algorithm).to equivalent_sarahs_skewb_algorithm(expected_rotation_algorithm, color_scheme)
    end
  end

  it_behaves_like 'corner rotations', %i[U F R], 'x y'
  it_behaves_like 'corner rotations', %i[U R B], "z' y"
  it_behaves_like 'corner rotations', %i[U B L], "y z'"
  it_behaves_like 'corner rotations', %i[U L F], "y x'"
  it_behaves_like 'corner rotations', %i[D R F], "y' x"
  it_behaves_like 'corner rotations', %i[D B R], "y' z'"
  it_behaves_like 'corner rotations', %i[D L B], "z' y'"
  it_behaves_like 'corner rotations', %i[D F L], "y' z"

  it 'rotates correctly back and forth around skewb corners' do
    property_of do
      Rantly { Tuple.new([corner, non_zero_skewb_direction]) }
    end.check do |t|
      c, d = t.array
      rotation_then_inverse = Core::Rotation.around_corner(c, d).inverse
      inverse_then_rotation = Core::Rotation.around_corner(c, d.inverse)
      expect(rotation_then_inverse).to equivalent_skewb_algorithm(inverse_then_rotation, color_scheme)
    end
  end

  it 'rotates correctly back and forth around cube corners' do
    property_of do
      Rantly { Tuple.new([corner, non_zero_skewb_direction]) }
    end.check do |t|
      c, d = t.array
      rotation_then_inverse = Core::Rotation.around_corner(c, d).inverse
      inverse_then_rotation = Core::Rotation.around_corner(c, d.inverse)
      expect(rotation_then_inverse).to equivalent_cube_algorithm(inverse_then_rotation, 3, color_scheme)
    end
  end

  it 'rotates cubes correctly' do
    state = color_scheme.solved_cube_state(3)
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(state) do
      expect(state).to eq_puzzle_state(color_scheme.solved_cube_state(3))
    end
  end

  it 'rotates skewbs correctly' do
    skewb_state = color_scheme.solved_skewb_state
    parse_fixed_corner_skewb_algorithm('x').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(Core::SkewbState.for_solved_colors(U: :red, F: :white, R: :green, L: :blue, B: :yellow, D: :orange))
    end
    parse_fixed_corner_skewb_algorithm('y').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(Core::SkewbState.for_solved_colors(U: :yellow, F: :green, R: :orange, L: :red, B: :blue, D: :white))
    end
    parse_fixed_corner_skewb_algorithm('z').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(Core::SkewbState.for_solved_colors(U: :blue, F: :red, R: :yellow, L: :white, B: :orange, D: :green))
    end
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R y U' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U y L' x' y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L y B' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B y R' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R z B' y2 z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U z L' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L z R' z2 y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B z U' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R x U' z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U x B' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L x R' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B x L' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
  end

  it 'recognizes equivalent rotations' do
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::Rotation.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE)).to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::DOUBLE), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE)).not_to be_equivalent(Core::Rotation.new(Core::Face::F, Core::CubeDirection::DOUBLE), 3)
  end
end
