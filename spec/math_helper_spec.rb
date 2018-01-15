require 'math_helper'

include CubeTrainer

describe MathHelper do
  include MathHelper

  it 'should round to numbers starting with 1, 2 or 5' do
    expect(round_to_nice(1.5)).to be_within(0.0001).of(1)
    expect(round_to_nice(2.5)).to be_within(0.0001).of(2)
    expect(round_to_nice(5.5)).to be_within(0.0001).of(5)
    expect(round_to_nice(10.5)).to be_within(0.001).of(10)
    expect(round_to_nice(12.5)).to be_within(0.001).of(10)
    expect(round_to_nice(15.5)).to be_within(0.001).of(10)
    expect(round_to_nice(0.015)).to be_within(0.000001).of(0.01)
    expect(round_to_nice(0.025)).to be_within(0.000001).of(0.02)
    expect(round_to_nice(0.055)).to be_within(0.000001).of(0.05)
  end
end
