# frozen_string_literal: true

require 'twisty_puzzles'
require 'rails_helper'

def casee(*part_cycles)
  Case.new(part_cycles: part_cycles)
end

describe Case do
  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:ur) { TwistyPuzzles::Edge.for_face_symbols(%i[U R]) }
  let(:uf_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[U F]) }
  let(:df_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[D F]) }
  let(:ub_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[U B]) }
  let(:uf_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U F]) }
  let(:ub_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U B]) }
  let(:ul_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U L]) }
  let(:ur_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U R]) }
  let(:edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ub]) }
  let(:midge_cycle) { TwistyPuzzles::PartCycle.new([uf_midge, df_midge, ub_midge]) }
  let(:uf_ub_tcenter_cycle) { TwistyPuzzles::PartCycle.new([uf_tcenter, ub_tcenter]) }
  let(:ur_ul_tcenter_cycle) { TwistyPuzzles::PartCycle.new([ur_tcenter, ul_tcenter]) }
  let(:modified_edge_cycle) { edge_cycle.rotate_by(1).map_rotate_by(1) }
  let(:other_edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ur]) }
  let(:first_swap) { TwistyPuzzles::PartCycle.new([uf, df], 1) }
  let(:modified_first_swap) { first_swap.rotate_by(1).map_rotate_by(1) }
  let(:second_swap) { TwistyPuzzles::PartCycle.new([ur, ub], 1) }
  let(:modified_second_swap) { second_swap.rotate_by(1).map_rotate_by(1) }
  let(:flipped_edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ub], 1) }

  describe '#valid?' do
    it 'returns true for an empty case' do
      expect(casee).to be_valid
    end

    it 'returns true for a valid three cycle' do
      expect(casee(edge_cycle)).to be_valid
    end

    it 'returns true for a valid double swap' do
      expect(casee(first_swap, second_swap)).to be_valid
    end

    it 'returns false for invalid part cycles types' do
      expect(casee(nil)).not_to be_valid
    end

    it 'returns false for invalid flips' do
      expect(casee(flipped_edge_cycle)).not_to be_valid
    end

    it 'returns false for intersecting cycles' do
      expect(casee(flipped_edge_cycle, other_edge_cycle)).not_to be_valid
    end
  end

  describe '#equivalent?' do
    it 'returns true for variations of the same 3 cycles' do
      expect(casee(edge_cycle).equivalent?(casee(modified_edge_cycle))).to be(true)
    end

    it 'returns true for variations of the same double swap' do
      expect(casee(first_swap, second_swap).equivalent?(casee(modified_second_swap, modified_first_swap))).to be(true)
    end

    it 'returns false for different cycles' do
      expect(casee(edge_cycle).equivalent?(casee(other_edge_cycle))).to be(false)
    end

    it 'returns false cycles with different twists' do
      expect(casee(edge_cycle).equivalent?(casee(flipped_edge_cycle))).to be(false)
    end

    it 'returns true for a center unsafe midge cycle vs its center safe version when ignoring same face center cycles' do
      expect(casee(midge_cycle, uf_ub_tcenter_cycle, ur_ul_tcenter_cycle).equivalent?(casee(midge_cycle), ignore_same_face_center_cycles: true)).to be(true)
    end

    it 'returns false for a center unsafe midge cycle vs its center safe version when not ignoring same face center cycles' do
      expect(casee(midge_cycle, uf_ub_tcenter_cycle, ur_ul_tcenter_cycle).equivalent?(casee(midge_cycle), ignore_same_face_center_cycles: false)).to be(false)
    end
  end

  describe '#canonicalize' do
    it 'changes nothing about an edge cycle' do
      expect(casee(edge_cycle).canonicalize(ignore_same_face_center_cycles: true)).to eq(casee(edge_cycle))
    end

    it 'changes nothing about a midge cycle' do
      expect(casee(midge_cycle).canonicalize(ignore_same_face_center_cycles: true)).to eq(casee(midge_cycle))
    end

    it 'changes nothing about a center unsafe midge cycle when not ignoring same face center cycles' do
      expect(casee(midge_cycle, uf_ub_tcenter_cycle, ur_ul_tcenter_cycle).canonicalize(ignore_same_face_center_cycles: false)).to eq(casee(midge_cycle, uf_ub_tcenter_cycle, ur_ul_tcenter_cycle))
    end

    it 'removes equivalent center cycles from a center unsafe midge cycle when ignoring same face center cycles' do
      expect(casee(midge_cycle, uf_ub_tcenter_cycle, ur_ul_tcenter_cycle).canonicalize(ignore_same_face_center_cycles: true)).to eq(casee(midge_cycle))
    end
  end
end
