# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe '#find_by' do
    it 'finds an existing achievement' do
      expect(described_class.find_by(key: :fake).key).to eq(:fake)
    end

    it 'returns nil for a non-existing achievement' do
      expect(described_class.find_by(key: :non_existing)).to be_nil
    end
  end

  describe '#find_by!' do
    it 'finds an existing achievement' do
      expect(described_class.find_by!(key: :fake).key).to eq(:fake)
    end

    it 'raises an ArgumentError for a non-existing achievement' do
      expect { described_class.find_by!(key: :non_existing) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_simple' do
    subject(:achievement) { described_class.find_by(key: :fake) }

    it 'returns a simple hash' do
      expect(achievement.to_simple).to eq({ key: :fake, name: 'Fake', description: 'Fake achievement for tests.' })
    end
  end
end
