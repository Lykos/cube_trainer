# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AchievementGrant, type: :model do
  include_context 'with achievement grant'

  let(:achievement) { Achievement.find_by(key: :fake) }

  describe '#to_simple' do
    it 'returns a simple hash' do
      expect(achievement_grant.to_simple).to include(achievement: achievement.to_simple)
    end
  end

  describe '#send_achievement_grant_message' do
    it 'sends a message on creation' do
      described_class.find_by(user: user, achievement: :fake)&.destroy!
      user.messages.clear

      described_class.create!(user: user, achievement: :fake)

      expect(user.messages.first.title).to include('Achievement Unlocked')
    end
  end
end
