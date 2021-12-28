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

  it 'creates an alg overrider achievement' do
    mode.stats.clear
    mode.stats.create!(stat_type: stat_type, index: 0)
    expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :stat_creator))).not_to be_nil
  end
end
