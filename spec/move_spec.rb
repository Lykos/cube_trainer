require 'move'
require 'cube_state'
require 'skewb_state'
require 'color_scheme'
require 'cube_print_helper'

include CubePrintHelper

describe Move do

  let (:color_scheme) { ColorScheme::BERNHARD }
  
  it 'should invert M slices correctly' do
    expect(parse_move("M").inverse).to be == parse_move("M'")
    expect(parse_move("M'").inverse).to be == parse_move("M")
    expect(parse_move("S").inverse).to be == parse_move("S'")
    expect(parse_move("S'").inverse).to be == parse_move("S")
    expect(parse_move("E").inverse).to be == parse_move("E'")
    expect(parse_move("E'").inverse).to be == parse_move("E")
  end

  it 'should rotate cubes correctly' do
    state = color_scheme.solved_cube_state(3)
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(state) do
      expect(state).to be == color_scheme.solved_cube_state(3)
    end
  end

  
  it 'should rotate skewbs correctly' do
    skewb_state = color_scheme.solved_skewb_state
    parse_fixed_corner_skewb_algorithm("x").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.new([:blue, :red, :yellow, :white, :orange, :green].map { |e| [e] * 5 })
    end
    parse_fixed_corner_skewb_algorithm("y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.new([:yellow, :blue, :red, :orange, :green, :white].map { |e| [e] * 5 })
    end
    parse_fixed_corner_skewb_algorithm("z").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.new([:red, :white, :green, :blue, :yellow, :orange].map { |e| [e] * 5 })
    end
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R y U' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U y L' x' y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L y B' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B y R' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R z B' y2 z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U z L' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L z R' z2 y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B z U' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("R x U' z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("U x B' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("L x R' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
    parse_fixed_corner_skewb_algorithm("B x L' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == color_scheme.solved_skewb_state
    end
  end
  
end
