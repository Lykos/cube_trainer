# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stat, type: :model do
  include_context 'with stat'

  let(:stat_type) { StatType.find_by(key: :averages) }

  describe '#to_simple' do
    it 'returns a simple hash' do
      expect(stat.to_simple).to include(stat_type: stat_type.to_simple, index: 0)
    end
  end

  describe '#create' do
    it 'creates a statistician achievement' do
      training_session.stats.clear
      training_session.stats.create!(stat_type: stat_type, index: 0)
      expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :statistician))).not_to be_nil
    end
  end
end
