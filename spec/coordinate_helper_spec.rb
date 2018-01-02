require 'coordinate_helper'

describe CoordinateHelper do
  include CoordinateHelper

  it 'should do the right thing for a corner' do
    expect(coordinate_rotations(0, 0, 5)).to be == [[0, 0], [0, 4], [4, 4], [4, 0]]
  end

  it 'should do the right thing for a midge' do
    expect(coordinate_rotations(0, 2, 5)).to be == [[0, 2], [2, 4], [4, 2], [2, 0]]
  end

  it 'should do the right thing for an oblique' do
    expect(coordinate_rotations(1, 2, 7)).to be == [[1, 2], [2, 5], [5, 4], [4, 1]]
  end
end
