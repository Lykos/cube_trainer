# frozen_string_literal: true

require 'cube_trainer/utils/sampling_helper'

describe Utils::SamplingHelper do
  include described_class

  let(:seed) { 42 }
  let(:random) { Random.new(seed) }

  it 'samples values approximately according to their desired frequencies' do
    array = [0, 1, 2]
    counts = {}
    counts.default = 0
    1000.times do
      value = sample_by(array, random) { |a| a**2 }
      counts[value] += 1
    end
    expect(counts.length).to eq(2)
    expect(counts[1]).to be_within(50).of(200)
    expect(counts[2]).to be_within(50).of(800)
  end

  it 'samples values uniformly among the ones with infinite weight' do
    array = [0, 1, 2]
    counts = {}
    counts.default = 0
    1000.times do
      value = sample_by(array, random) { |a| a.positive? ? Float::INFINITY : 1 }
      counts[value] += 1
    end
    expect(counts.length).to eq(2)
    expect(counts[1]).to be_within(50).of(500)
    expect(counts[2]).to be_within(50).of(500)
  end

  it 'raises an error for an empty array' do
    expect { sample_by([]) { |a| a } }.to raise_error(ArgumentError)
  end

  it 'raises an error for a weight sum of 0' do
    expect { sample_by([1]) { |_a| 0 } }.to raise_error(ArgumentError)
  end

  it 'raises an error for a negative weight' do
    expect { sample_by([1]) { |_a| -1 } }.to raise_error(ArgumentError)
  end

  it 'raises an error for a weight that is not a number' do
    expect { sample_by([1]) { |_a| '' } }.to raise_error(TypeError)
  end
end
