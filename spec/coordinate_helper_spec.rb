require 'coordinate_helper'

include CubeTrainer

describe CoordinateHelper do
  context 'for an uneven n' do
    let (:n) { 7 }

    include CoordinateHelper

    it 'should check equivalence of coordinates appropriately' do
      expect(equivalent_coordinates([1, 0], [1, -7])).to be true
      expect(equivalent_coordinates([2, 0], [1, -7])).to be false
    end
    
    it 'should check coordinates appropriately' do
      expect(valid_coordinate?(1.0)).to be false
      expect(valid_coordinate?(-7)).to be true
      expect(valid_coordinate?(-8)).to be false
      expect(valid_coordinate?(7)).to be false
      expect(valid_coordinate?(0)).to be true
      expect(valid_coordinate?(5)).to be true
      expect(valid_coordinate?(6)).to be true
    end

    it 'should check whether something is before the middle' do
      expect(is_before_middle?(-7)).to be true
      expect(is_before_middle?(-6)).to be true
      expect(is_before_middle?(-5)).to be true
      expect(is_before_middle?(-4)).to be false
      expect(is_before_middle?(-3)).to be false
      expect(is_before_middle?(-2)).to be false
      expect(is_before_middle?(-1)).to be false
      expect(is_before_middle?(0)).to be true
      expect(is_before_middle?(1)).to be true
      expect(is_before_middle?(2)).to be true
      expect(is_before_middle?(3)).to be false
      expect(is_before_middle?(4)).to be false
      expect(is_before_middle?(5)).to be false
      expect(is_before_middle?(6)).to be false
    end

    it 'should check whether something is after the middle' do
      expect(is_after_middle?(-7)).to be false
      expect(is_after_middle?(-6)).to be false
      expect(is_after_middle?(-5)).to be false
      expect(is_after_middle?(-4)).to be false
      expect(is_after_middle?(-3)).to be true
      expect(is_after_middle?(-2)).to be true
      expect(is_after_middle?(-1)).to be true
      expect(is_after_middle?(0)).to be false
      expect(is_after_middle?(1)).to be false
      expect(is_after_middle?(2)).to be false
      expect(is_after_middle?(3)).to be false
      expect(is_after_middle?(4)).to be true
      expect(is_after_middle?(5)).to be true
      expect(is_after_middle?(6)).to be true
    end
    
    it 'should make coordinates positive correctly' do
      expect(make_positive(-7)).to be 0
      expect(make_positive(-6)).to be 1
      expect(make_positive(-5)).to be 2
      expect(make_positive(-4)).to be 3
      expect(make_positive(-3)).to be 4
      expect(make_positive(-2)).to be 5
      expect(make_positive(-1)).to be 6
      expect(make_positive(0)).to be 0
      expect(make_positive(1)).to be 1
      expect(make_positive(2)).to be 2
      expect(make_positive(3)).to be 3
      expect(make_positive(4)).to be 4
      expect(make_positive(5)).to be 5
      expect(make_positive(6)).to be 6
    end

    it 'should return the right last before middle' do
      expect(last_before_middle).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(middle_or_before).to be 3
    end
    
    it 'should return the right middle' do
      expect(middle).to be 3
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
      expect(coordinate_rotations([0, 0])).to be == [[0, 0], [0, -1], [-1, -1], [-1, 0]]
    end
    
    it 'should do the right thing for a wing' do
      expect(coordinate_rotations([0, 2])).to be == [[0, 2], [2, -1], [-1, -3], [-3, 0]]
    end
    
    it 'should do the right thing for a midge' do
      expect(coordinate_rotations([0, 3])).to be == [[0, 3], [3, -1], [-1, -4], [-4, 0]]
    end

    it 'should do the right thing for an oblique' do
      expect(coordinate_rotations([1, 2])).to be == [[1, 2], [2, -2], [-2, -3], [-3, 1]]
    end
  end
  
  context 'for an even n' do
    let (:n) { 6 }
    
    include CoordinateHelper

    it 'should check equivalence of coordinates appropriately' do
      expect(equivalent_coordinates([1, 0], [1, -6])).to be true
      expect(equivalent_coordinates([2, 0], [1, -6])).to be false
    end

    it 'should check coordinates appropriately' do
      expect(valid_coordinate?(1.0)).to be false
      expect(valid_coordinate?(-6)).to be true
      expect(valid_coordinate?(-7)).to be false
      expect(valid_coordinate?(6)).to be false
      expect(valid_coordinate?(0)).to be true
      expect(valid_coordinate?(4)).to be true
      expect(valid_coordinate?(5)).to be true
    end

    it 'should check whether something is before the middle' do
      expect(is_before_middle?(-6)).to be true
      expect(is_before_middle?(-5)).to be true
      expect(is_before_middle?(-4)).to be true
      expect(is_before_middle?(-3)).to be false
      expect(is_before_middle?(-2)).to be false
      expect(is_before_middle?(-1)).to be false
      expect(is_before_middle?(0)).to be true
      expect(is_before_middle?(1)).to be true
      expect(is_before_middle?(2)).to be true
      expect(is_before_middle?(3)).to be false
      expect(is_before_middle?(4)).to be false
      expect(is_before_middle?(5)).to be false
    end

    it 'should check whether something is after the middle' do
      expect(is_after_middle?(-6)).to be false
      expect(is_after_middle?(-5)).to be false
      expect(is_after_middle?(-4)).to be false
      expect(is_after_middle?(-3)).to be true
      expect(is_after_middle?(-2)).to be true
      expect(is_after_middle?(-1)).to be true
      expect(is_after_middle?(0)).to be false
      expect(is_after_middle?(1)).to be false
      expect(is_after_middle?(2)).to be false
      expect(is_after_middle?(3)).to be true
      expect(is_after_middle?(4)).to be true
      expect(is_after_middle?(5)).to be true
    end
    
    it 'should make coordinates positive correctly' do
      expect(make_positive(-6)).to be 0
      expect(make_positive(-5)).to be 1
      expect(make_positive(-4)).to be 2
      expect(make_positive(-3)).to be 3
      expect(make_positive(-2)).to be 4
      expect(make_positive(-1)).to be 5
      expect(make_positive(0)).to be 0
      expect(make_positive(1)).to be 1
      expect(make_positive(2)).to be 2
      expect(make_positive(3)).to be 3
      expect(make_positive(4)).to be 4
      expect(make_positive(5)).to be 5
    end

    it 'should return the right last before middle' do
      expect(last_before_middle).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(middle_or_before).to be 2
    end
    
    it 'should raise for getting the middle' do
      expect { middle }.to raise_error(ArgumentError)
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
      expect(coordinate_rotations([0, 0])).to be == [[0, 0], [0, -1], [-1, -1], [-1, 0]]
    end
    
    it 'should do the right thing for a wing' do
      expect(coordinate_rotations([0, 2])).to be == [[0, 2], [2, -1], [-1, -3], [-3, 0]]
    end

    it 'should do the right thing for an oblique' do
      expect(coordinate_rotations([1, 2])).to be == [[1, 2], [2, -2], [-2, -3], [-3, 1]]
    end
  end
end
