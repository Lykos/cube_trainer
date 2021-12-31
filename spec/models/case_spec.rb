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
  let(:edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ub]) }
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
  end
end
