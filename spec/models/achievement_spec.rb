# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe '#find_by' do
    it 'finds an existing achievement' do
      expect(described_class.find_by(id: :fake).id).to eq(:fake)
    end

    it 'returns nil for a non-existing achievement' do
      expect(described_class.find_by(id: :non_existing)).to be_nil
    end
  end

  describe '#find' do
    it 'finds an existing achievement' do
      expect(described_class.find(:fake).id).to eq(:fake)
    end

    it 'raises an ArgumentError for a non-existing achievement' do
      expect { described_class.find(:non_existing) }.to raise_error(ArgumentError)
    end
  end
end
