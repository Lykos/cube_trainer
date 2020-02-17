# frozen_string_literal: true

require 'cube_trainer/utils/array_helper'

describe Utils::ArrayHelper do
  include Utils::ArrayHelper

  it 'should permute empty arrays' do
    expect(apply_permutation([], [])).to be == []
  end

  it 'should permute singleton arrays' do
    expect(apply_permutation([2], [0])).to be == [2]
  end

  it 'should permute letter arrays' do
    expect(apply_permutation(%w[a b c d], [0, 2, 1, 3])).to be == %w[a c b d]
  end

  it 'should do nothing if there are no nils' do
    expect(rotate_out_nils([1, 2, 3])).to be == [1, 2, 3]
  end

  it 'should do nothing if for an empty array' do
    expect(rotate_out_nils([])).to be == []
  end

  it 'should return an empty array if there are only nils' do
    expect(rotate_out_nils([nil, nil, nil])).to be == []
  end

  it 'should remove nils at the end' do
    expect(rotate_out_nils([1, 2, 3, nil, nil, nil])).to be == [1, 2, 3]
  end

  it 'should remove nils at the beginning' do
    expect(rotate_out_nils([nil, nil, nil, 1, 2, 3])).to be == [1, 2, 3]
  end

  it 'should remove nils at the outside' do
    expect(rotate_out_nils([nil, nil, 1, 2, 3, nil])).to be == [1, 2, 3]
  end

  it 'should rotate and remove nils in the middle' do
    expect(rotate_out_nils([3, nil, nil, nil, 1, 2])).to be == [1, 2, 3]
    expect(rotate_out_nils([2, 3, nil, nil, nil, 1])).to be == [1, 2, 3]
  end

  it 'should raise an exception if there are multiple nil periods' do
    expect { expect(rotate_out_nils([3, nil, 1, nil, 2])).to be }.to raise_error ArgumentError
  end

  it 'should find the only element in an array' do
    expect(only([1])).to be == 1
  end

  it 'should raise when trying to get the only element in an empty array' do
    expect { only([]) }.to raise_error ArgumentError
  end

  it 'should raise when trying to get the only element in an array with multiple elements' do
    expect { only([1, 2]) }.to raise_error ArgumentError
  end

  it 'should replace one element once in an array' do
    expect(replace_once([1, 2, 3], 1, 5)).to be == [5, 2, 3]
  end

  it 'should raise an exception if a non-existing element should be replaced once in an array' do
    expect { replace_once([1, 2, 3], 5, 1) }.to raise_error ArgumentError
  end

  it 'should raise an exception if an element that appears multiple time should be ' \
     'replaced once in an array' do
    expect { replace_once([1, 1, 3], 1, 5) }.to raise_error ArgumentError
  end
end
