# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/move'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/parser'

describe Core::Move do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }

  it 'inverts M slices correctly' do
    expect(parse_move('M').inverse).to(be == parse_move("M'"))
    expect(parse_move("M'").inverse).to(be == parse_move('M'))
    expect(parse_move('S').inverse).to(be == parse_move("S'"))
    expect(parse_move("S'").inverse).to(be == parse_move('S'))
    expect(parse_move('E').inverse).to(be == parse_move("E'"))
    expect(parse_move("E'").inverse).to(be == parse_move('E'))
  end

  it 'rotates cubes correctly' do
    state = color_scheme.solved_cube_state(3)
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(state) do
      expect(state).to(be == color_scheme.solved_cube_state(3))
    end
  end

  it 'rotates skewbs correctly' do
    skewb_state = color_scheme.solved_skewb_state
    parse_fixed_corner_skewb_algorithm('x').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == Core::SkewbState.for_solved_colors(U: :red, F: :white, R: :green, L: :blue, B: :yellow, D: :orange))
    end
    parse_fixed_corner_skewb_algorithm('y').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == Core::SkewbState.for_solved_colors(U: :yellow, F: :green, R: :orange, L: :red, B: :blue, D: :white))
    end
    parse_fixed_corner_skewb_algorithm('z').apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == Core::SkewbState.for_solved_colors(U: :blue, F: :red, R: :yellow, L: :white, B: :orange, D: :green))
    end
    parse_fixed_corner_skewb_algorithm("x y z' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R y U' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U y L' x' y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L y B' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B y R' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R z B' y2 z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U z L' y'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L z R' z2 y").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B z U' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("R x U' z y2").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("U x B' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("L x R' z'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
    parse_fixed_corner_skewb_algorithm("B x L' x'").apply_temporarily_to(skewb_state) do
      expect(skewb_state).to(be == color_scheme.solved_skewb_state)
    end
  end

  it 'sorts moves by type then face then direction' do
    expect(parse_algorithm('U') < parse_algorithm('M')).to(be(true))
    expect(parse_algorithm('U') < parse_algorithm('F')).to(be(true))
    expect(parse_algorithm('U') < parse_algorithm("U'")).to(be(true))
  end

  it 'recognizes equivalent rotations' do
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::Rotation.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)).to(be(true))
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::Rotation.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)).to(be(false))
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::Rotation.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)).to(be(false))
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE).equivalent?(Core::Rotation.new(Core::Face::D, Core::CubeDirection::DOUBLE), 3)).to(be(true))
    expect(Core::Rotation.new(Core::Face::U, Core::CubeDirection::DOUBLE).equivalent?(Core::Rotation.new(Core::Face::F, Core::CubeDirection::DOUBLE), 3)).to(be(false))
  end

  it 'recognizes equivalent fat M-slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)).to(be(true))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)).to(be(false))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)).to(be(false))
  end

  it 'recognizes equivalent fat M-slice and slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 3)).to(be(true))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 3)).to(be(true))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 4)).to(be(false))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 4)).to(be(false))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1), 3)).to(be(false))
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).equivalent?(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 1), 3)).to(be(false))

    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD), 3)).to(be(true))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)).to(be(true))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD), 4)).to(be(false))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 4)).to(be(false))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)).to(be(false))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)).to(be(false))
  end

  it 'recognizes equivalent slice moves' do
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 2), 4)).to(be(true))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 4)).to(be(false))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 2), 4)).to(be(false))
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 2), 4)).to(be(false))
  end

  it 'recognizes equivalent normal moves' do
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 3)).to(be(true))
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 2), 3)).to(be(false))
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 1), 3)).to(be(false))
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1), 3)).to(be(false))
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).equivalent?(Core::FatMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 3)).to(be(false))
  end

  it 'returns the right string representation for inner m slice moves' do
    expect(Core::InnerMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to(be == "E'")
    expect(Core::InnerMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'S')
    expect(Core::InnerMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to(be == "M'")
    expect(Core::InnerMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'M')
    expect(Core::InnerMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to(be == "S'")
    expect(Core::InnerMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'E')
  end

  it 'returns the right string representation for fat m slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to(be == "E'")
    expect(Core::FatMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to(be == 'S')
    expect(Core::FatMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to(be == "M'")
    expect(Core::FatMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to(be == 'M')
    expect(Core::FatMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to(be == "S'")
    expect(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to(be == 'E')
  end

  it 'returns the right string representation for maybe fat maybe inner m slice moves' do
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to(be == "E'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to(be == 'S')
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to(be == "M'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to(be == 'M')
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to(be == "S'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to(be == 'E')
  end

  it 'returns the right string representation for slice moves' do
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'u')
    expect(Core::SliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'f')
    expect(Core::SliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'r')
    expect(Core::SliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'l')
    expect(Core::SliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'b')
    expect(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'd')
  end

  it 'returns the right string representation for fat moves' do
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'U')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'F')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'R')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'L')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'B')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to(be == 'D')

    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Uw')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Fw')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Rw')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Lw')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Bw')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 2).to_s).to(be == 'Dw')

    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Uw')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Fw')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Rw')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Lw')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Bw')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 3).to_s).to(be == '3Dw')
  end

  it 'returns the right string representation for maybe fat maybe slice moves' do
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to(be == 'u')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to(be == 'f')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to(be == 'r')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to(be == 'l')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to(be == 'b')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to(be == 'd')
  end

  it 'raises if asked to translate a direction to a face that is neither its axis face nor its axis face opposite' do
    move = Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)
    expect { move.translated_direction(Core::Face::F) }.to(raise_error(ArgumentError))
  end

  it 'raises if asked to translate a slice index to a face that is neither its axis face nor its axis face opposite' do
    move = Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)
    expect { move.translated_slice_index(Core::Face::F) }.to(raise_error(ArgumentError))
  end

  it 'raises if asked to decide the meaning of a move like u that can be a slice move on big cubes or a fat move on 3x3 on 2x2' do
    move = Core::MaybeFatMaybeSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)
    expect { move.decide_meaning(2) }.to(raise_error(ArgumentError))
  end
end
