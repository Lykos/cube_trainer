# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'
require 'cube_trainer/training/case_set'

RSpec.describe Alg, type: :model do
  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      training_session_type: TrainingSessionType.find_by!(key: :edge_commutators),
      sheet_title: 'UF',
      case_set: Training::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, TwistyPuzzles::Edge.for_face_symbols(%i[U F]))
    )
  end

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { alg_set.algs }
  end
end
