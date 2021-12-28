# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Result, type: :model do
  include_context 'with mode'

  describe '#valid?' do
  end

  describe '#to_dump' do
    it 'returns a simple hash' do
      result = mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
      expect(result.to_dump).to include(case_key: 'A B', time_s: 10, success: true)
    end
  end

  describe '#to_simple' do
    it 'returns a simple hash' do
      result = mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
      expect(result.to_simple).to include(case_key: 'LetterPair:a b', time_s: 10, success: true)
    end
  end

  describe '#time' do
    it 'returns the seconds' do
      result = mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
      expect(result.time).to eq(10.seconds)
    end

    it 'returns nil if the time is nil' do
      result = mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]))
      expect(result.time).to be_nil
    end
  end

  describe '#create' do
    it 'creates an enthusiast achievement after 100 results' do
      user.achievement_grants.clear
      mode.results.clear
      100.times do
        mode.results.create!(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
      end
      expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :enthusiast))).not_to be_nil
    end

    it 'creates no achievement after 99 results' do
      user.achievement_grants.clear
      mode.results.clear
      99.times do
        mode.results.create!(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
      end
      expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :enthusiast))).to be_nil
    end
  end
end
