# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg do
  include_context 'with alg spreadsheet'

  let(:fu_r) { TwistyPuzzles::Wing.for_face_symbols(%i[F U R]) }
  let(:fl_u) { TwistyPuzzles::Wing.for_face_symbols(%i[F L U]) }
  let(:ld_b) { TwistyPuzzles::Wing.for_face_symbols(%i[L D B]) }
  let(:db_l) { TwistyPuzzles::Wing.for_face_symbols(%i[D B L]) }
  let(:wing_case_set) { CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Wing, fu_r) }
  let(:wing_alg_set) { alg_spreadsheet.alg_sets.create!(case_set: wing_case_set, sheet_title: 'wings') }

  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      training_session_type: TrainingSessionType.find(:edge_commutators),
      sheet_title: 'UF',
      case_set: CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, TwistyPuzzles::Edge.for_face_symbols(%i[U F]))
    )
  end

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { alg_set.algs }
  end

  it 'returns true for a valid alg with very fat moves' do
    alg = wing_alg_set.algs.new(
      casee: Case.new(part_cycles: [TwistyPuzzles::PartCycle.new([fu_r, fl_u, ld_b])]),
      alg: "[3Lw' U: [R' d R, U]]"
    )
    expect(alg).to be_valid
  end

  it 'returns true for a valid alg with fat slice moves' do
    alg = wing_alg_set.algs.new(
      casee: Case.new(part_cycles: [TwistyPuzzles::PartCycle.new([fu_r, fl_u, db_l])]),
      alg: "[U' M: [U, R' u' R]]"
    )
    expect(alg).to be_valid
  end
end
