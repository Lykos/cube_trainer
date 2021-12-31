require 'cube_trainer/training/case_pattern'
require 'rails_helper'
require 'twisty_puzzles'

describe Training::CasePattern do
  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:ur) { TwistyPuzzles::Edge.for_face_symbols(%i[U R]) }
  let(:edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ub]) }
  let(:other_edge_cycle) { TwistyPuzzles::PartCycle.new([ub, df, ur]) }
  let(:uf_pattern) { Training::CasePattern::SpecificPart.new(uf) }
  let(:fu_pattern) { Training::CasePattern::SpecificPart.new(fu) }
  let(:ub_pattern) { Training::CasePattern::SpecificPart.new(ub) }
  let(:wildcard) { Training::CasePattern::PartWildcard.new }
  let(:edge_cycle_pattern) { Training::CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [uf_pattern, wildcard, wildcard]) }
  let(:equivalent_edge_cycle_pattern) { Training::CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [wildcard, fu_pattern, wildcard]) }
  let(:other_edge_cycle_pattern) { Training::CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [ub_pattern, wildcard, wildcard]) }
  let(:ufr) { TwistyPuzzles::Corner.for_face_symbols(%i[U R F]) }
  let(:fur) { TwistyPuzzles::Corner.for_face_symbols(%i[F U R]) }
  let(:ubl) { TwistyPuzzles::Corner.for_face_symbols(%i[U B L]) }
  let(:ufl) { TwistyPuzzles::Corner.for_face_symbols(%i[U F L]) }
  let(:corner_cycle) { TwistyPuzzles::PartCycle.new([ufr, ubl, ufl]) }
  let(:ufr_pattern) { Training::CasePattern::SpecificPart.new(ufr) }
  let(:fur_pattern) { Training::CasePattern::SpecificPart.new(fur) }
  let(:corner_cycle_pattern) { Training::CasePattern::PartCyclePattern.new(TwistyPuzzles::Corner, [ufr_pattern, wildcard, wildcard]) }
  let(:equivalent_corner_cycle_pattern) { Training::CasePattern::PartCyclePattern.new(TwistyPuzzles::Corner, [wildcard, fur_pattern, wildcard]) }
  let(:case_pattern) { Training::CasePattern.new([edge_cycle_pattern, corner_cycle_pattern]) }
  let(:equivalent_case_pattern) { Training::CasePattern.new([equivalent_corner_cycle_pattern, equivalent_edge_cycle_pattern]) }
  let(:other_case_pattern) { Training::CasePattern.new([other_edge_cycle_pattern, corner_cycle_pattern]) }
  let(:casee) { Case.new(part_cycles: [edge_cycle, corner_cycle]) }
  let(:other_case) { Case.new(part_cycles: [other_edge_cycle, corner_cycle]) }
  
  describe '==' do
    it 'should be equal to itself' do
      expect(case_pattern == case_pattern).to eq(true)
    end

    it 'should be equal to an equivalent one' do
      expect(case_pattern == equivalent_case_pattern).to eq(true)
    end

    it 'should not be equal to a different one' do
      expect(case_pattern == other_case_pattern).to eq(false)
    end
  end

  describe '#hash' do
    it 'should be equal to its own hash' do
      expect(case_pattern.hash == case_pattern.hash).to eq(true)
    end

    it 'should be equal to the hash of an equivalent one' do
      expect(case_pattern.hash == equivalent_case_pattern.hash).to eq(true)
    end

    it 'should not be equal to a different one' do
      expect(case_pattern.hash == other_case_pattern.hash).to eq(false)
    end
  end

  describe '#match?' do
    it 'should match a fitting case' do
      expect(case_pattern.match?(casee)).to be(true)
    end

    it 'should match a tricky fitting case' do
      expect(equivalent_case_pattern.match?(casee)).to be(true)
    end

    it 'should match a fitting case' do
      expect(case_pattern.match?(other_case)).to be(false)
    end
  end
end
