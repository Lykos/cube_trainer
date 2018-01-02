require 'array_helper'

describe ArrayHelper do
  include ArrayHelper

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
end
