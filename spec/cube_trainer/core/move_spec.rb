# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/move'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/parser'

describe Move do
  let (:color_scheme) { ColorScheme::BERNHARD }

  it 'should invert M slices correctly' do
    expect(parse_move('M').inverse).to be == parse_move("M'")
    expect(parse_move("M'").inverse).to be == parse_move('M')
    expect(parse_move('S').inverse).to be == parse_move("S'")
    expect(parse_move("S'").inverse).to be == parse_move('S')
    expect(parse_move('E').inverse).to be == parse_move("E'")
    expect(parse_move("E'").inverse).to be == parse_move('E')
  end

  it 'should rotate cubes correctly' do
    state = color_scheme.solved_cube_state(3)
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(state) do
      expect(state).to be == color_scheme.solved_cube_state(3)
    end
  end

  it 'should rotate skewbs correctly' do
    skewb_state = color_scheme.solved_skewb_state
    parse_fixed_corner_skewb_algorithm('x').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors(U: :red, F: :white, R: :green, L: :blue, B: :yellow, D: :orange)
    end
    parse_fixed_corner_skewb_algorithm('y').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors(U: :yellow, F: :green, R: :orange, L: :red, B: :blue, D: :white)
    end
    parse_fixed_corner_skewb_algorithm('z').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to be == SkewbState.for_solved_colors(U: :blue, F: :red, R: :yellow, L: :white, B: :orange, D: :green)
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

  it 'should sort moves by type then face then direction' do
    expect(parse_algorithm('U') < parse_algorithm('M')).to be true
    expect(parse_algorithm('U') < parse_algorithm('F')).to be true
    expect(parse_algorithm('U') < parse_algorithm("U'")).to be true
  end

  it 'should recognize equivalent rotations' do
    expect(Rotation.new(Face::U, CubeDirection::FORWARD).equivalent?(Rotation.new(Face::D, CubeDirection::BACKWARD), 3)).to be true
    expect(Rotation.new(Face::U, CubeDirection::FORWARD).equivalent?(Rotation.new(Face::D, CubeDirection::FORWARD), 3)).to be false
    expect(Rotation.new(Face::U, CubeDirection::FORWARD).equivalent?(Rotation.new(Face::U, CubeDirection::BACKWARD), 3)).to be false
    expect(Rotation.new(Face::U, CubeDirection::DOUBLE).equivalent?(Rotation.new(Face::D, CubeDirection::DOUBLE), 3)).to be true
    expect(Rotation.new(Face::U, CubeDirection::DOUBLE).equivalent?(Rotation.new(Face::F, CubeDirection::DOUBLE), 3)).to be false
  end

  it 'should recognize equivalent fat M-slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 3)).to be true
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(FatMSliceMove.new(Face::D, CubeDirection::FORWARD), 3)).to be false
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(FatMSliceMove.new(Face::U, CubeDirection::BACKWARD), 3)).to be false
  end

  it 'should recognize equivalent fat M-slice and slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::U, CubeDirection::FORWARD, 1), 3)).to be true
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 3)).to be true
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::U, CubeDirection::FORWARD, 1), 4)).to be false
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 4)).to be false
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::D, CubeDirection::FORWARD, 1), 3)).to be false
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).equivalent?(SliceMove.new(Face::U, CubeDirection::BACKWARD, 1), 3)).to be false

    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::U, CubeDirection::FORWARD), 3)).to be true
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 3)).to be true
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::U, CubeDirection::FORWARD), 4)).to be false
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::D, CubeDirection::BACKWARD), 4)).to be false
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::D, CubeDirection::FORWARD), 3)).to be false
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMSliceMove.new(Face::U, CubeDirection::BACKWARD), 3)).to be false
  end

  it 'should recognize equivalent slice moves' do
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(SliceMove.new(Face::D, CubeDirection::BACKWARD, 2), 4)).to be true
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(SliceMove.new(Face::D, CubeDirection::BACKWARD, 1), 4)).to be false
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(SliceMove.new(Face::D, CubeDirection::FORWARD, 2), 4)).to be false
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(SliceMove.new(Face::U, CubeDirection::BACKWARD, 2), 4)).to be false
  end

  it 'should recognize equivalent normal moves' do
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMove.new(Face::U, CubeDirection::FORWARD, 1), 3)).to be true
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMove.new(Face::U, CubeDirection::FORWARD, 2), 3)).to be false
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMove.new(Face::U, CubeDirection::BACKWARD, 1), 3)).to be false
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMove.new(Face::D, CubeDirection::FORWARD, 1), 3)).to be false
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).equivalent?(FatMove.new(Face::D, CubeDirection::BACKWARD, 1), 3)).to be false
  end

  it 'should return the right string representation for inner m slice moves' do
    expect(InnerMSliceMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to be == "E'"
    expect(InnerMSliceMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to be == 'S'
    expect(InnerMSliceMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to be == "M'"
    expect(InnerMSliceMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to be == 'M'
    expect(InnerMSliceMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to be == "S'"
    expect(InnerMSliceMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to be == 'E'
  end

  it 'should return the right string representation for fat m slice moves' do
    expect(FatMSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to be == "E'"
    expect(FatMSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to be == 'S'
    expect(FatMSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to be == "M'"
    expect(FatMSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to be == 'M'
    expect(FatMSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to be == "S'"
    expect(FatMSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to be == 'E'
  end

  it 'should return the right string representation for maybe fat maybe inner m slice moves' do
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to be == "E'"
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to be == 'S'
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to be == "M'"
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to be == 'M'
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to be == "S'"
    expect(MaybeFatMSliceMaybeInnerMSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to be == 'E'
  end

  it 'should return the right string representation for slice moves' do
    expect(SliceMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to be == 'u'
    expect(SliceMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to be == 'f'
    expect(SliceMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to be == 'r'
    expect(SliceMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to be == 'l'
    expect(SliceMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to be == 'b'
    expect(SliceMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to be == 'd'
  end

  it 'should return the right string representation for fat moves' do
    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 1).to_s).to be == 'U'
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 1).to_s).to be == 'F'
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 1).to_s).to be == 'R'
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 1).to_s).to be == 'L'
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 1).to_s).to be == 'B'
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 1).to_s).to be == 'D'

    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 2).to_s).to be == 'Uw'
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 2).to_s).to be == 'Fw'
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 2).to_s).to be == 'Rw'
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 2).to_s).to be == 'Lw'
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 2).to_s).to be == 'Bw'
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 2).to_s).to be == 'Dw'

    expect(FatMove.new(Face::U, CubeDirection::FORWARD, 3).to_s).to be == '3Uw'
    expect(FatMove.new(Face::F, CubeDirection::FORWARD, 3).to_s).to be == '3Fw'
    expect(FatMove.new(Face::R, CubeDirection::FORWARD, 3).to_s).to be == '3Rw'
    expect(FatMove.new(Face::L, CubeDirection::FORWARD, 3).to_s).to be == '3Lw'
    expect(FatMove.new(Face::B, CubeDirection::FORWARD, 3).to_s).to be == '3Bw'
    expect(FatMove.new(Face::D, CubeDirection::FORWARD, 3).to_s).to be == '3Dw'
  end

  it 'should return the right string representation for maybe fat maybe slice moves' do
    expect(MaybeFatMaybeSliceMove.new(Face::U, CubeDirection::FORWARD).to_s).to be == 'u'
    expect(MaybeFatMaybeSliceMove.new(Face::F, CubeDirection::FORWARD).to_s).to be == 'f'
    expect(MaybeFatMaybeSliceMove.new(Face::R, CubeDirection::FORWARD).to_s).to be == 'r'
    expect(MaybeFatMaybeSliceMove.new(Face::L, CubeDirection::FORWARD).to_s).to be == 'l'
    expect(MaybeFatMaybeSliceMove.new(Face::B, CubeDirection::FORWARD).to_s).to be == 'b'
    expect(MaybeFatMaybeSliceMove.new(Face::D, CubeDirection::FORWARD).to_s).to be == 'd'
  end

  it 'should raise if asked to translate a direction to a face that is neither its axis face nor its axis face opposite' do
    move = FatMove.new(Face::U, CubeDirection::FORWARD, 1)
    expect { move.translated_direction(Face::F) }.to raise_error(ArgumentError)
  end

  it 'should raise if asked to translate a slice index to a face that is neither its axis face nor its axis face opposite' do
    move = SliceMove.new(Face::U, CubeDirection::FORWARD, 1)
    expect { move.translated_slice_index(Face::F) }.to raise_error(ArgumentError)
  end

  it 'should raise if asked to decide the meaning of a move like u that can be a slice move on big cubes or a fat move on 3x3 on 2x2' do
    move = MaybeFatMaybeSliceMove.new(Face::U, CubeDirection::FORWARD)
    expect { move.decide_meaning(2) }.to raise_error(ArgumentError)
  end
end
