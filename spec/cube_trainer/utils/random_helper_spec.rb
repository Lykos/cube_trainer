# frozen_string_literal: true

require 'cube_trainer/utils/random_helper'

describe Utils::RandomHelper do
  include described_class

  it 'distorts a value not more than the given factor' do
    100.times do
      distorted = distort(100, 0.1)
      expect(distorted).to be <= 110
      expect(distorted).to be >= 90
    end
  end

  it 'raises an error for a zero factor' do
    expect { distort(100, 0) }.to raise_error(ArgumentError)
  end

  it 'raises an error for a negative factor' do
    expect { distort(100, -1) }.to raise_error(ArgumentError)
  end

  it 'raises an error for a factor bigger than 1' do
    expect { distort(100, 2) }.to raise_error(ArgumentError)
  end
end
