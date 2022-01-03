# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

def create_case(*parts)
  casee = Case.new(part_cycles: [TwistyPuzzles::PartCycle.new(parts)])
  casee.validate!
  casee
end

RSpec.describe AlgSet, type: :model do
  include TwistyPuzzles

  include_context 'with alg spreadsheet'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:ur) { TwistyPuzzles::Edge.for_face_symbols(%i[U R]) }
  let(:commutator) { parse_commutator("[M', U2]") }

  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      training_session_type: TrainingSessionType.find_by!(key: :edge_commutators),
      sheet_title: 'UF',
      case_set: CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, TwistyPuzzles::Edge.for_face_symbols(%i[U F]))
    )
  end

  let(:alg) do
    alg_set.algs.create!(
      casee: create_case(uf, df, ub),
      alg: commutator.to_s
    )
  end

  describe '#alg' do
    it 'finds a commutator for the given case' do
      alg
      expect(alg_set.commutator(create_case(uf, df, ub))).to eq(commutator)
    end

    it 'finds a commutator for the given case based on its inverse' do
      alg
      expect(alg_set.commutator(create_case(uf, ub, df))).to eq(commutator.inverse)
    end

    it 'returns nil if there is no commutator for the given case' do
      alg
      expect(alg_set.commutator(create_case(uf, ur, ub))).to be(nil)
    end
  end
end
