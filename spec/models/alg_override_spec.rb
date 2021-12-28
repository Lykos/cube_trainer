# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg, type: :model do
  include_context 'with mode'
  include_context 'with user abc'
  include_context 'with alg spreadsheet'

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { mode.alg_overrides }
  end

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }

  it 'creates an alg overrider achievement' do
    user.achievement_grants.clear
    mode.alg_overrides.create!(
      case_key: TwistyPuzzles::PartCycle.new([uf, df, ub]),
      alg: "M' U2 M U2"
    )
    expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :alg_overrider))).not_to be_nil
  end
end
