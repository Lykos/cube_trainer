# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/rotation'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/skewb_notation'
require 'cube_trainer/core/skewb_state'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe Core::Rotation do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:fixed_corner) { Core::SkewbNotation.fixed_corner }

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
    parse_skewb_algorithm("x y z' y'", fixed_corner).apply_to(state)
    expect(state).to eq_puzzle_state(color_scheme.solved_cube_state(3))
  end

  shared_examples 'skewb rotation' do |alg_string, skewb_state|
    it "rotates skewbs correctly in algorithm #{alg_string}" do
      state = color_scheme.solved_skewb_state
      parse_skewb_algorithm(alg_string, fixed_corner).apply_to(state)
      expect(state).to eq_puzzle_state(skewb_state)
    end
  end

  include_examples 'skewb rotation', 'x', Core::SkewbState.for_solved_colors(U: :red, F: :white, R: :green, L: :blue, B: :yellow, D: :orange)
  include_examples 'skewb rotation', 'y', Core::SkewbState.for_solved_colors(U: :yellow, F: :green, R: :orange, L: :red, B: :blue, D: :white)
  include_examples 'skewb rotation', 'z', Core::SkewbState.for_solved_colors(U: :blue, F: :red, R: :yellow, L: :white, B: :orange, D: :green)

  shared_examples 'trivial skewb algorithm' do |alg_string|
    it "reaches the original state again in trivial algorithm #{alg_string}" do
      state = color_scheme.solved_skewb_state
      parse_skewb_algorithm(alg_string, fixed_corner).apply_to(state)
      expect(state).to eq_puzzle_state(color_scheme.solved_skewb_state)
    end
  end

  include_examples 'trivial skewb algorithm', "x y z' y'"
  include_examples 'trivial skewb algorithm', "R y U' x'"
  include_examples 'trivial skewb algorithm', "U y L' x' y2"
  include_examples 'trivial skewb algorithm', "L y B' y'"
  include_examples 'trivial skewb algorithm', "B y R' y'"
  include_examples 'trivial skewb algorithm', "R z B' y2 z y2"
  include_examples 'trivial skewb algorithm', "U z L' y'"
  include_examples 'trivial skewb algorithm', "L z R' z2 y"
  include_examples 'trivial skewb algorithm', "B z U' z'"
  include_examples 'trivial skewb algorithm', "R x U' z y2"
  include_examples 'trivial skewb algorithm', "U x B' x'"
  include_examples 'trivial skewb algorithm', "L x R' z'"
  include_examples 'trivial skewb algorithm', "B x L' x'"

  it 'recognizes equivalent rotations' do
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::Rotation.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE)).to be_equivalent(Core::Rotation.new(Core::Face::D, Core::CubeDirection::DOUBLE), 3)
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE)).not_to be_equivalent(Core::Rotation.new(Core::Face::F, Core::CubeDirection::DOUBLE), 3)
  end
end
