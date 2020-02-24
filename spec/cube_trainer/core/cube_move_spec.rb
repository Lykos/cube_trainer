# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_move'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/parser'

describe Core::CubeMove do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }

  it 'inverts M slices correctly' do
    expect(parse_move('M').inverse).to eq_move("M'")
    expect(parse_move("M'").inverse).to eq_move('M')
    expect(parse_move('S').inverse).to eq_move("S'")
    expect(parse_move("S'").inverse).to eq_move('S')
    expect(parse_move('E').inverse).to eq_move("E'")
    expect(parse_move("E'").inverse).to eq_move('E')
  end

  it 'recognizes equivalent fat M-slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).to be_equivalent(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)
  end

  it 'recognizes equivalent fat M-slice and slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).to be_equivalent(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 3)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 3)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 4)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 4)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1), 3)
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)).not_to be_equivalent(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 1), 3)

    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).to be_equivalent(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD), 3)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).to be_equivalent(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 3)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD), 4)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD), 4)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD), 3)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD), 3)
  end

  it 'recognizes equivalent slice moves' do
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 2), 4)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 4)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 2), 4)
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 2), 4)
  end

  it 'recognizes equivalent normal moves' do
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).to be_equivalent(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1), 3)
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 2), 3)
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMove.new(Core::Face::U, Core::CubeDirection::BACKWARD, 1), 3)
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1), 3)
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)).not_to be_equivalent(Core::FatMove.new(Core::Face::D, Core::CubeDirection::BACKWARD, 1), 3)
  end

  it 'returns the right string representation for inner m slice moves' do
    expect(Core::InnerMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to eq("E'")
    expect(Core::InnerMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to eq('S')
    expect(Core::InnerMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to eq("M'")
    expect(Core::InnerMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to eq('M')
    expect(Core::InnerMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to eq("S'")
    expect(Core::InnerMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to eq('E')
  end

  it 'returns the right string representation for fat m slice moves' do
    expect(Core::FatMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to eq("E'")
    expect(Core::FatMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to eq('S')
    expect(Core::FatMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to eq("M'")
    expect(Core::FatMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to eq('M')
    expect(Core::FatMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to eq("S'")
    expect(Core::FatMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to eq('E')
  end

  it 'returns the right string representation for maybe fat maybe inner m slice moves' do
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to eq("E'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to eq('S')
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to eq("M'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to eq('M')
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to eq("S'")
    expect(Core::MaybeFatMSliceMaybeInnerMSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to eq('E')
  end

  it 'returns the right string representation for slice moves' do
    expect(Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to eq('u')
    expect(Core::SliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to eq('f')
    expect(Core::SliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to eq('r')
    expect(Core::SliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to eq('l')
    expect(Core::SliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to eq('b')
    expect(Core::SliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to eq('d')
  end

  it 'returns the right string representation for fat moves' do
    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1).to_s).to eq('U')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 1).to_s).to eq('F')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 1).to_s).to eq('R')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 1).to_s).to eq('L')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 1).to_s).to eq('B')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 1).to_s).to eq('D')

    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 2).to_s).to eq('Uw')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 2).to_s).to eq('Fw')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 2).to_s).to eq('Rw')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 2).to_s).to eq('Lw')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 2).to_s).to eq('Bw')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 2).to_s).to eq('Dw')

    expect(Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Uw')
    expect(Core::FatMove.new(Core::Face::F, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Fw')
    expect(Core::FatMove.new(Core::Face::R, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Rw')
    expect(Core::FatMove.new(Core::Face::L, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Lw')
    expect(Core::FatMove.new(Core::Face::B, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Bw')
    expect(Core::FatMove.new(Core::Face::D, Core::CubeDirection::FORWARD, 3).to_s).to eq('3Dw')
  end

  it 'returns the right string representation for maybe fat maybe slice moves' do
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD).to_s).to eq('u')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::F, Core::CubeDirection::FORWARD).to_s).to eq('f')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::R, Core::CubeDirection::FORWARD).to_s).to eq('r')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::L, Core::CubeDirection::FORWARD).to_s).to eq('l')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::B, Core::CubeDirection::FORWARD).to_s).to eq('b')
    expect(Core::MaybeFatMaybeSliceMove.new(Core::Face::D, Core::CubeDirection::FORWARD).to_s).to eq('d')
  end

  it 'raises if asked to translate a direction to a face that is neither its axis face nor its axis face opposite' do
    move = Core::FatMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)
    expect { move.translated_direction(Core::Face::F) }.to raise_error(ArgumentError)
  end

  it 'raises if asked to translate a slice index to a face that is neither its axis face nor its axis face opposite' do
    move = Core::SliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD, 1)
    expect { move.translated_slice_index(Core::Face::F) }.to raise_error(ArgumentError)
  end

  it 'raises if asked to decide the meaning of a move like u that can be a slice move on big cubes or a fat move on 3x3 on 2x2' do
    move = Core::MaybeFatMaybeSliceMove.new(Core::Face::U, Core::CubeDirection::FORWARD)
    expect { move.decide_meaning(2) }.to raise_error(ArgumentError)
  end
end
