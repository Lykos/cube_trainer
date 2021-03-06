# frozen_string_literal: true

require 'cube_trainer/utils/math_helper'

describe Utils::MathHelper do
  include described_class

  it 'floors to numbers starting with 1, 2 or 5' do
    expect(floor_to_nice(1.5)).to be_within(0.0001).of(1)
    expect(floor_to_nice(2.5)).to be_within(0.0001).of(2)
    expect(floor_to_nice(5.5)).to be_within(0.0001).of(5)
    expect(floor_to_nice(10.5)).to be_within(0.001).of(10)
    expect(floor_to_nice(12.5)).to be_within(0.001).of(10)
    expect(floor_to_nice(15.5)).to be_within(0.001).of(10)
    expect(floor_to_nice(0.015)).to be_within(0.000001).of(0.01)
    expect(floor_to_nice(0.025)).to be_within(0.000001).of(0.02)
    expect(floor_to_nice(0.055)).to be_within(0.000001).of(0.05)
  end

  it 'floors to steps appropriately' do
    expect(floor_to_step(1, 0.1)).to be_within(0.0001).of(1)
    expect(floor_to_step(0.9, 0.2)).to be_within(0.0001).of(0.8)
    expect(floor_to_step(12.01, 0.03)).to be_within(0.0001).of(12)
  end
end
