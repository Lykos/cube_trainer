# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

describe CasePattern::CasePattern do
  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:ur) { TwistyPuzzles::Edge.for_face_symbols(%i[U R]) }
  let(:uf_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[U F]) }
  let(:ub_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[U B]) }
  let(:lu_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[L U]) }
  let(:fu_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[F U]) }
  let(:bu_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[B U]) }
  let(:ul_midge) { TwistyPuzzles::Midge.for_face_symbols(%i[U L]) }
  let(:uf_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U F]) }
  let(:ub_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U B]) }
  let(:ul_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U L]) }
  let(:ur_tcenter) { TwistyPuzzles::TCenter.for_face_symbols(%i[U R]) }
  let(:edge_cycle) { TwistyPuzzles::PartCycle.new([uf, df, ub]) }
  let(:other_edge_cycle) { TwistyPuzzles::PartCycle.new([ub, df, ur]) }
  let(:midge_cycle) { TwistyPuzzles::PartCycle.new([bu_midge, ul_midge, fu_midge]) }
  let(:uf_ub_tcenter_cycle) { TwistyPuzzles::PartCycle.new([uf_tcenter, ub_tcenter]) }
  let(:ul_ur_tcenter_cycle) { TwistyPuzzles::PartCycle.new([ul_tcenter, ur_tcenter]) }
  let(:uf_pattern) { CasePattern::SpecificPart.new(uf) }
  let(:fu_pattern) { CasePattern::SpecificPart.new(fu) }
  let(:ub_pattern) { CasePattern::SpecificPart.new(ub) }
  let(:uf_midge_pattern) { CasePattern::SpecificPart.new(uf_midge) }
  let(:ub_midge_pattern) { CasePattern::SpecificPart.new(ub_midge) }
  let(:lu_midge_pattern) { CasePattern::SpecificPart.new(lu_midge) }
  let(:wildcard) { CasePattern::PartWildcard.new }
  let(:edge_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [uf_pattern, wildcard, wildcard]) }
  let(:equivalent_edge_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [wildcard, fu_pattern, wildcard]) }
  let(:other_edge_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Edge, [ub_pattern, wildcard, wildcard]) }
  let(:midge_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Midge, [uf_midge_pattern, ub_midge_pattern, lu_midge_pattern]) }
  let(:ufr) { TwistyPuzzles::Corner.for_face_symbols(%i[U R F]) }
  let(:fur) { TwistyPuzzles::Corner.for_face_symbols(%i[F U R]) }
  let(:ubl) { TwistyPuzzles::Corner.for_face_symbols(%i[U B L]) }
  let(:ufl) { TwistyPuzzles::Corner.for_face_symbols(%i[U F L]) }
  let(:corner_cycle) { TwistyPuzzles::PartCycle.new([ufr, ubl, ufl]) }
  let(:ufr_pattern) { CasePattern::SpecificPart.new(ufr) }
  let(:fur_pattern) { CasePattern::SpecificPart.new(fur) }
  let(:corner_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Corner, [ufr_pattern, wildcard, wildcard]) }
  let(:equivalent_corner_cycle_pattern) { CasePattern::PartCyclePattern.new(TwistyPuzzles::Corner, [wildcard, fur_pattern, wildcard]) }
  let(:case_pattern) { CasePattern::LeafCasePattern.new([edge_cycle_pattern, corner_cycle_pattern], ignore_same_face_center_cycles: true) }
  let(:equivalent_case_pattern) { CasePattern::LeafCasePattern.new([equivalent_corner_cycle_pattern, equivalent_edge_cycle_pattern], ignore_same_face_center_cycles: true) }
  let(:other_case_pattern) { CasePattern::LeafCasePattern.new([other_edge_cycle_pattern, corner_cycle_pattern], ignore_same_face_center_cycles: true) }
  let(:midge_case_pattern) { CasePattern::LeafCasePattern.new([midge_cycle_pattern], ignore_same_face_center_cycles: true) }
  let(:strict_midge_case_pattern) { CasePattern::LeafCasePattern.new([midge_cycle_pattern], ignore_same_face_center_cycles: false) }
  let(:casee) { Case.new(part_cycles: [edge_cycle, corner_cycle]) }
  let(:other_case) { Case.new(part_cycles: [other_edge_cycle, corner_cycle]) }
  let(:midge_case) { Case.new(part_cycles: [midge_cycle]) }
  let(:center_unsafe_midge_case) { Case.new(part_cycles: [midge_cycle, uf_ub_tcenter_cycle, ul_ur_tcenter_cycle]) }

  describe '==' do
    it 'is equal to itself' do
      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      expect(case_pattern == case_pattern).to be(true)
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands
    end

    it 'is equal to an equivalent one' do
      expect(case_pattern == equivalent_case_pattern).to be(true)
    end

    it 'is not equal to a different one' do
      expect(case_pattern == other_case_pattern).to be(false)
    end
  end

  describe '#hash' do
    it 'is equal to its own hash' do
      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      expect(case_pattern.hash == case_pattern.hash).to be(true)
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands
    end

    it 'is equal to the hash of an equivalent one' do
      expect(case_pattern.hash == equivalent_case_pattern.hash).to be(true)
    end

    it 'is not equal to a different one' do
      expect(case_pattern.hash == other_case_pattern.hash).to be(false)
    end
  end

  describe '#match?' do
    it 'matches a fitting case' do
      expect(case_pattern.match?(casee)).to be(true)
    end

    it 'matches a tricky fitting case' do
      expect(equivalent_case_pattern.match?(casee)).to be(true)
    end

    it 'does not match a non-fitting case' do
      expect(case_pattern.match?(other_case)).to be(false)
    end

    it 'matches a tricky fitting midge case' do
      expect(midge_case_pattern.match?(midge_case)).to be(true)
      expect(strict_midge_case_pattern.match?(midge_case)).to be(true)
    end

    it 'matches a center unsafe fitting midge case when ignoring equivalent center cycles' do
      expect(midge_case_pattern.match?(center_unsafe_midge_case)).to be(true)
    end

    it 'does not match a center unsafe fitting midge case when not ignoring equivalent center cycles' do
      expect(strict_midge_case_pattern.match?(center_unsafe_midge_case)).to be(false)
    end
  end
end
