# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/rotation'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/parser'

describe Core::Rotation do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }

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
