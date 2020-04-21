# frozen_string_literal: true

require 'twisty_puzzles/utils/array_helper'

describe TwistyPuzzles::Utils::ArrayHelper do
  include described_class

  it 'permutes empty arrays' do
    expect(apply_permutation([], [])).to be_empty
  end

  it 'permutes singleton arrays' do
    expect(apply_permutation([2], [0])).to contain_exactly(2)
  end

  it 'permutes letter arrays' do
    expect(apply_permutation(%w[a b c d], [0, 2, 1, 3])).to eq(%w[a c b d])
  end

  it 'does nothing if there are no nils' do
    expect(rotate_out_nils([1, 2, 3])).to contain_exactly(1, 2, 3)
  end

  it 'does nothing if for an empty array' do
    expect(rotate_out_nils([])).to be_empty
  end

  it 'returns an empty array if there are only nils' do
    expect(rotate_out_nils([nil, nil, nil])).to be_empty
  end

  it 'removes nils at the end' do
    expect(rotate_out_nils([1, 2, 3, nil, nil, nil])).to contain_exactly(1, 2, 3)
  end

  it 'removes nils at the beginning' do
    expect(rotate_out_nils([nil, nil, nil, 1, 2, 3])).to contain_exactly(1, 2, 3)
  end

  it 'removes nils at the outside' do
    expect(rotate_out_nils([nil, nil, 1, 2, 3, nil])).to contain_exactly(1, 2, 3)
  end

  it 'rotates and remove nils in the middle' do
    expect(rotate_out_nils([3, nil, nil, nil, 1, 2])).to contain_exactly(1, 2, 3)
    expect(rotate_out_nils([2, 3, nil, nil, nil, 1])).to contain_exactly(1, 2, 3)
  end

  it 'raises an exception if there are multiple nil periods' do
    expect { rotate_out_nils([3, nil, 1, nil, 2]) }.to raise_error(ArgumentError)
  end

  it 'finds the only element in an array' do
    expect(only([1])).to eq(1)
  end

  it 'raises when trying to get the only element in an empty array' do
    expect { only([]) }.to raise_error(ArgumentError)
  end

  it 'raises when trying to get the only element in an array with multiple elements' do
    expect { only([1, 2]) }.to raise_error(ArgumentError)
  end

  it 'finds the only even element in an array' do
    expect(find_only([1, 2, 5, 7], &:even?)).to eq(2)
  end

  it 'raises when trying to find the only even element in an empty array' do
    expect { find_only([], &:even?) }.to raise_error(ArgumentError)
  end

  it 'raises when trying to find the only even element in an array with no even numbers' do
    expect { find_only([1, 3, 5], &:even?) }.to raise_error(ArgumentError)
  end

  it 'raises when trying to find the only even element in an array with several even numbers' do
    expect { find_only([1, 2, 4], &:even?) }.to raise_error(ArgumentError)
  end

  it 'replaces one element once in an array' do
    expect(replace_once([1, 2, 3], 1, 5)).to contain_exactly(5, 2, 3)
  end

  it 'raises an exception if a non-existing element should be replaced once in an array' do
    expect { replace_once([1, 2, 3], 5, 1) }.to raise_error(ArgumentError)
  end

  it 'raises an exception if an element that appears multiple time should be replaced ' \
     'once in an array' do
    expect { replace_once([1, 1, 3], 1, 5) }.to raise_error(ArgumentError)
  end
end
