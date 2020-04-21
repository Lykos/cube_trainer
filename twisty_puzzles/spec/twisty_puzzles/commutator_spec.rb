# frozen_string_literal: true

require 'twisty_puzzles/commutator'
require 'twisty_puzzles/parser'

describe PureCommutator do
  

  let(:commutator) { parse_commutator('[R, U\' L\' U]') }

  it 'is equal to the inverse of its inverse' do
    expect(commutator.inverse.inverse).to eq(commutator)
  end

  it 'is inverted appropriately' do
    expect(commutator.inverse.to_s).to eq('[U\' L\' U, R]')
  end

  it 'is printed appropriately' do
    expect(commutator.to_s).to eq('[R, U\' L\' U]')
  end
end

describe SetupCommutator do
  

  let(:commutator) { parse_commutator('[U\' : [R, U\' L\' U]]') }
  let(:rotation_commutator) { parse_commutator('[x2 : [R, U\' L\' U]]') }

  it 'is equal to the inverse of its inverse' do
    expect(commutator.inverse.inverse).to eq(commutator)
  end

  it 'is inverted appropriately' do
    expect(commutator.inverse.to_s).to eq('[U\' : [U\' L\' U, R]]')
  end

  it 'is printed appropriately' do
    expect(commutator.to_s).to eq('[U\' : [R, U\' L\' U]]')
  end

  it 'is printed appropriately even with rotations' do
    expect(rotation_commutator.to_s).to eq('[x2 : [R, U\' L\' U]]')
  end
end
