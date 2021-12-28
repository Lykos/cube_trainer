# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Result, type: :model do
  include_context 'with mode'

  describe '#valid?' do
    it 'returns true for a valid result' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 0, failed_attempts: 1, success: true, num_hints: 1)).not_to be_valid
    end

    it 'returns false for a negative time' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: -1)).not_to be_valid
    end

    it 'returns false for a zero time' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 0)).not_to be_valid
    end

    it 'returns false for a negative number of failed attempts' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10, failed_attempts: -1)).not_to be_valid
    end

    it 'returns false for a non-integral number of failed attempts' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10, failed_attempts: 1.1)).not_to be_valid
    end

    it 'returns false for a negative number of hints' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10, num_hints: -1)).not_to be_valid
    end

    it 'returns false for a non-integral number of hints' do
      expect(mode.results.new(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10, num_hints: 1.1)).not_to be_valid
    end
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
