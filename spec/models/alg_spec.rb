# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg, type: :model do
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
end
