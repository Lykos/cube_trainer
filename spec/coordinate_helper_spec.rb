require 'coordinate_helper'

describe CoordinateHelper do
  context 'for an uneven n' do
    let (:n) { 7 }

    include CoordinateHelper

    it 'should check coordinates appropriately' do
      expect(valid_coordinate?(1.0)).to be false
      expect(valid_coordinate?(-1)).to be false
      expect(valid_coordinate?(7)).to be false
      expect(valid_coordinate?(0)).to be true
      expect(valid_coordinate?(5)).to be true
      expect(valid_coordinate?(6)).to be true
    end

    it 'should return the right last before middle' do
      expect(last_before_middle).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(middle_or_before).to be 3
    end
    
    it 'should return the right middle or after' do
      expect(middle_or_after).to be 3
    end

    it 'should return the right highest coordinate' do
      expect(highest_coordinate).to be 6
    end
    
    it 'should invert coordinates correctly' do
      expect(invert_coordinate(0)).to be 6
      expect(invert_coordinate(1)).to be 5
      expect(invert_coordinate(2)).to be 4
      expect(invert_coordinate(3)).to be 3
      expect(invert_coordinate(4)).to be 2
      expect(invert_coordinate(5)).to be 1
      expect(invert_coordinate(6)).to be 0
    end
    
    it 'should do the right thing for a corner' do
      expect(coordinate_rotations(0, 0)).to be == [[0, 0], [0, 6], [6, 6], [6, 0]]
    end
    
    it 'should do the right thing for a wing' do
      expect(coordinate_rotations(0, 2)).to be == [[0, 2], [2, 6], [6, 4], [4, 0]]
    end
    
    it 'should do the right thing for a midge' do
      expect(coordinate_rotations(0, 3)).to be == [[0, 3], [3, 6], [6, 3], [3, 0]]
    end

    it 'should do the right thing for an oblique' do
      expect(coordinate_rotations(1, 2)).to be == [[1, 2], [2, 5], [5, 4], [4, 1]]
    end
  end
  
  context 'for an even n' do
    let (:n) { 6 }
    
    include CoordinateHelper

    it 'should check coordinates appropriately' do
      expect(valid_coordinate?(1.0)).to be false
      expect(valid_coordinate?(-1)).to be false
      expect(valid_coordinate?(7)).to be false
      expect(valid_coordinate?(0)).to be true
      expect(valid_coordinate?(4)).to be true
      expect(valid_coordinate?(5)).to be true
    end

    it 'should return the right last before middle' do
      expect(last_before_middle).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(middle_or_before).to be 2
    end
    
    it 'should return the right middle or after' do
      expect(middle_or_after).to be 3
    end

    it 'should return the right highest coordinate' do
      expect(highest_coordinate).to be 5
    end
    
    it 'should invert coordinates correctly' do
      expect(invert_coordinate(0)).to be 5
      expect(invert_coordinate(1)).to be 4
      expect(invert_coordinate(2)).to be 3
      expect(invert_coordinate(3)).to be 2
      expect(invert_coordinate(4)).to be 1
      expect(invert_coordinate(5)).to be 0
    end
    
    it 'should do the right thing for a corner' do
      expect(coordinate_rotations(0, 0)).to be == [[0, 0], [0, 5], [5, 5], [5, 0]]
    end
    
    it 'should do the right thing for a wing' do
      expect(coordinate_rotations(0, 2)).to be == [[0, 2], [2, 5], [5, 3], [3, 0]]
    end

    it 'should do the right thing for an oblique' do
      expect(coordinate_rotations(1, 2)).to be == [[1, 2], [2, 4], [4, 3], [3, 1]]
    end
  end
end
