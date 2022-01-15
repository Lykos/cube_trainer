# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg, type: :model do
  include_context 'with training session'
  include_context 'with user abc'
  include_context 'with alg spreadsheet'
  include_context 'with case'

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { training_session.alg_overrides }
  end

  it 'creates an alg overrider achievement' do
    user.achievement_grants.clear
    training_session.alg_overrides.create!(
      casee: casee,
      alg: "M' U2 M U2"
    )
    expect(user.achievement_grants.find_by(achievement: Achievement.find_by(id: :alg_overrider))).not_to be_nil
  end
end
