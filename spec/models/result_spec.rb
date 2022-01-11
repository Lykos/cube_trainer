# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Result, type: :model do
  include_context 'with training session'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:casee) { Case.new(part_cycles: [TwistyPuzzles::PartCycle.new([uf, df, ub])]) }

  describe '#valid?' do
    it 'returns true for a valid result' do
      expect(training_session.results.new(casee: casee, time_s: 0, failed_attempts: 1, success: true, num_hints: 1)).not_to be_valid
    end

    it 'returns false for a negative time' do
      expect(training_session.results.new(casee: casee, time_s: -1)).not_to be_valid
    end

    it 'returns false for a zero time' do
      expect(training_session.results.new(casee: casee, time_s: 0)).not_to be_valid
    end

    it 'returns false for a negative number of failed attempts' do
      expect(training_session.results.new(casee: casee, time_s: 10, failed_attempts: -1)).not_to be_valid
    end

    it 'returns false for a non-integral number of failed attempts' do
      expect(training_session.results.new(casee: casee, time_s: 10, failed_attempts: 1.1)).not_to be_valid
    end

    it 'returns false for a negative number of hints' do
      expect(training_session.results.new(casee: casee, time_s: 10, num_hints: -1)).not_to be_valid
    end

    it 'returns false for a non-integral number of hints' do
      expect(training_session.results.new(casee: casee, time_s: 10, num_hints: 1.1)).not_to be_valid
    end
  end

  describe '#to_dump' do
    it 'returns a simple hash' do
      result = training_session.results.new(casee: casee, time_s: 10)
      expect(result.to_dump).to include(case_key: 'Edge(UF DF UB)', time_s: 10, success: true)
    end
  end

  describe '#to_simple' do
    subject(:result) { training_session.results.new(casee: casee, time_s: 10) }

    context 'when no letter scheme is defined' do
      it 'returns a simple hash with no letter scheme applied' do
        expect(result.to_simple).to include(case_key: 'Edge(UF DF UB)', case_name: 'DF UB', time_s: 10, success: true)
      end
    end

    context 'when a letter scheme is defined' do
      include_context 'with letter scheme'

      it 'returns a simple hash with the letter scheme applied' do
        letter_scheme
        expect(result.to_simple).to include(case_key: 'Edge(UF DF UB)', case_name: 'U D', time_s: 10, success: true)
      end
    end
  end

  describe '#time' do
    it 'returns the seconds' do
      result = training_session.results.new(casee: casee, time_s: 10)
      expect(result.time).to eq(10.seconds)
    end

    it 'returns nil if the time is nil' do
      result = training_session.results.new(casee: casee)
      expect(result.time).to be_nil
    end
  end

  describe '#create' do
    it 'creates an enthusiast achievement after 100 results' do
      user.achievement_grants.clear
      training_session.results.clear
      100.times do
        training_session.results.create!(casee: casee, time_s: 10)
      end
      expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :enthusiast))).not_to be_nil
    end

    it 'creates no achievement after 99 results' do
      user.achievement_grants.clear
      training_session.results.clear
      99.times do
        training_session.results.create!(casee: casee, time_s: 10)
      end
      expect(user.achievement_grants.find_by(achievement: Achievement.find_by(key: :enthusiast))).to be_nil
    end
  end
end
