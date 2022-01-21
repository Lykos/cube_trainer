# frozen_string_literal: true

require 'rails_helper'
require 'byebug'

RSpec.describe Stat, type: :model do
  include_context 'with stat'

  let(:stat_type) { :averages }

  describe '#create' do
    it 'creates a statistician achievement' do
      training_session.stats.clear
      training_session.stats.create!(stat_type: stat_type, index: 0)
      expected_achievement = Achievement.find_by(id: :statistician)
      expect(user.achievement_grants.find_by(achievement: expected_achievement)).not_to be_nil
    end
  end
end
