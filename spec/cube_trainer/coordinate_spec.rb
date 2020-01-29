require 'cube_trainer/coordinate'
require 'cube_trainer/cube'

include CubeTrainer

describe Coordinate do
  let (:coordinate) { Coordinate.from_indices(Face::U, n, 0, 1) }

  context 'for an uneven n' do
    let (:n) { 7 }

    it 'should check equivalence of coordinates appropriately' do
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, 0)).to be true
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, -7)).to be true
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::D, n, 1, 0)).to be false
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, -1)).to be false
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n + 2, 1, 0)).to be false
    end
    
    it 'should return the values passed in the constructor via the getters' do
      expect(coordinate.face).to be == Face::U
      expect(coordinate.cube_size).to be == n
      expect(coordinate.x).to be == 0
      expect(coordinate.y).to be == 1
    end
    
    it 'should check coordinates appropriately' do
      expect { Coordinate.from_indices(Face::U, n, 0, 1.0) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, -7) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, -8) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, 7) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, 0) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, 5) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, 6) }.not_to raise_error
    end

    it 'should check whether something is before the middle' do
      expect(coordinate.is_before_middle?(-7)).to be true
      expect(coordinate.is_before_middle?(-6)).to be true
      expect(coordinate.is_before_middle?(-5)).to be true
      expect(coordinate.is_before_middle?(-4)).to be false
      expect(coordinate.is_before_middle?(-3)).to be false
      expect(coordinate.is_before_middle?(-2)).to be false
      expect(coordinate.is_before_middle?(-1)).to be false
      expect(coordinate.is_before_middle?(0)).to be true
      expect(coordinate.is_before_middle?(1)).to be true
      expect(coordinate.is_before_middle?(2)).to be true
      expect(coordinate.is_before_middle?(3)).to be false
      expect(coordinate.is_before_middle?(4)).to be false
      expect(coordinate.is_before_middle?(5)).to be false
      expect(coordinate.is_before_middle?(6)).to be false
    end

    it 'should check whether something is after the middle' do
      expect(coordinate.is_after_middle?(-7)).to be false
      expect(coordinate.is_after_middle?(-6)).to be false
      expect(coordinate.is_after_middle?(-5)).to be false
      expect(coordinate.is_after_middle?(-4)).to be false
      expect(coordinate.is_after_middle?(-3)).to be true
      expect(coordinate.is_after_middle?(-2)).to be true
      expect(coordinate.is_after_middle?(-1)).to be true
      expect(coordinate.is_after_middle?(0)).to be false
      expect(coordinate.is_after_middle?(1)).to be false
      expect(coordinate.is_after_middle?(2)).to be false
      expect(coordinate.is_after_middle?(3)).to be false
      expect(coordinate.is_after_middle?(4)).to be true
      expect(coordinate.is_after_middle?(5)).to be true
      expect(coordinate.is_after_middle?(6)).to be true
    end
    
    it 'should make coordinates positive correctly' do
      expect(Coordinate.canonicalize(-7, n)).to be 0
      expect(Coordinate.canonicalize(-6, n)).to be 1
      expect(Coordinate.canonicalize(-5, n)).to be 2
      expect(Coordinate.canonicalize(-4, n)).to be 3
      expect(Coordinate.canonicalize(-3, n)).to be 4
      expect(Coordinate.canonicalize(-2, n)).to be 5
      expect(Coordinate.canonicalize(-1, n)).to be 6
      expect(Coordinate.canonicalize(0, n)).to be 0
      expect(Coordinate.canonicalize(1, n)).to be 1
      expect(Coordinate.canonicalize(2, n)).to be 2
      expect(Coordinate.canonicalize(3, n)).to be 3
      expect(Coordinate.canonicalize(4, n)).to be 4
      expect(Coordinate.canonicalize(5, n)).to be 5
      expect(Coordinate.canonicalize(6, n)).to be 6
    end

    it 'should return the right last before middle' do
      expect(Coordinate.last_before_middle(n)).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(Coordinate.middle_or_before(n)).to be 3
    end
    
    it 'should return the right middle' do
      expect(Coordinate.middle(n)).to be 3
    end
    
    it 'should return the right middle or after' do
      expect(Coordinate.middle_or_after(n)).to be 3
    end

    it 'should return the right highest coordinate' do
      expect(Coordinate.highest_coordinate(n)).to be 6
    end
    
    it 'should invert coordinates correctly' do
      expect(Coordinate.invert_coordinate(0, n)).to be 6
      expect(Coordinate.invert_coordinate(1, n)).to be 5
      expect(Coordinate.invert_coordinate(2, n)).to be 4
      expect(Coordinate.invert_coordinate(3, n)).to be 3
      expect(Coordinate.invert_coordinate(4, n)).to be 2
      expect(Coordinate.invert_coordinate(5, n)).to be 1
      expect(Coordinate.invert_coordinate(6, n)).to be 0
    end
    
    it 'should do the right thing for a corner' do
      expect(Coordinate.from_indices(Face::U, n, 0, 0).rotations).to be == [Coordinate.from_indices(Face::U, n, 0, 0), Coordinate.from_indices(Face::U, n, 0, -1), Coordinate.from_indices(Face::U, n, -1, -1), Coordinate.from_indices(Face::U, n, -1, 0)]
    end
    
    it 'should do the right thing for a wing' do
      expect(Coordinate.from_indices(Face::U, n, 0, 2).rotations).to be == [Coordinate.from_indices(Face::U, n, 0, 2), Coordinate.from_indices(Face::U, n, 2, -1), Coordinate.from_indices(Face::U, n, -1, -3), Coordinate.from_indices(Face::U, n, -3, 0)]
    end
    
    it 'should do the right thing for a midge' do
      expect(Coordinate.from_indices(Face::U, n, 0, 3).rotations).to be == [Coordinate.from_indices(Face::U, n, 0, 3), Coordinate.from_indices(Face::U, n, 3, -1), Coordinate.from_indices(Face::U, n, -1, -4), Coordinate.from_indices(Face::U, n, -4, 0)]
    end

    it 'should do the right thing for an oblique' do
      expect(Coordinate.from_indices(Face::U, n, 1, 2).rotations).to be == [Coordinate.from_indices(Face::U, n, 1, 2), Coordinate.from_indices(Face::U, n, 2, -2), Coordinate.from_indices(Face::U, n, -2, -3), Coordinate.from_indices(Face::U, n, -3, 1)]
    end
  end
  
  context 'for an even n' do
    let (:n) { 6 } 
   
    it 'should check equivalence of coordinates appropriately' do
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, 0)).to be true
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, -6)).to be true
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::D, n, 1, 0)).to be false
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n, 1, -1)).to be false
      expect(Coordinate.from_indices(Face::U, n, 1, 0) == Coordinate.from_indices(Face::U, n + 2, 1, 0)).to be false
    end

    it 'should check coordinates appropriately' do
      expect { Coordinate.from_indices(Face::U, n, 0, 1.0) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, -6) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, -7) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, 6) }.to raise_error(ArgumentError)
      expect { Coordinate.from_indices(Face::U, n, 0, 0) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, 4) }.not_to raise_error
      expect { Coordinate.from_indices(Face::U, n, 0, 5) }.not_to raise_error
    end

    it 'should return the values passed in the constructor via the getters' do
      expect(coordinate.face).to be == Face::U
      expect(coordinate.cube_size).to be == n
      expect(coordinate.x).to be == 0
      expect(coordinate.y).to be == 1
    end
    
    it 'should check whether something is before the middle' do
      expect(coordinate.is_before_middle?(-6)).to be true
      expect(coordinate.is_before_middle?(-5)).to be true
      expect(coordinate.is_before_middle?(-4)).to be true
      expect(coordinate.is_before_middle?(-3)).to be false
      expect(coordinate.is_before_middle?(-2)).to be false
      expect(coordinate.is_before_middle?(-1)).to be false
      expect(coordinate.is_before_middle?(0)).to be true
      expect(coordinate.is_before_middle?(1)).to be true
      expect(coordinate.is_before_middle?(2)).to be true
      expect(coordinate.is_before_middle?(3)).to be false
      expect(coordinate.is_before_middle?(4)).to be false
      expect(coordinate.is_before_middle?(5)).to be false
    end

    it 'should check whether something is after the middle' do
      expect(coordinate.is_after_middle?(-6)).to be false
      expect(coordinate.is_after_middle?(-5)).to be false
      expect(coordinate.is_after_middle?(-4)).to be false
      expect(coordinate.is_after_middle?(-3)).to be true
      expect(coordinate.is_after_middle?(-2)).to be true
      expect(coordinate.is_after_middle?(-1)).to be true
      expect(coordinate.is_after_middle?(0)).to be false
      expect(coordinate.is_after_middle?(1)).to be false
      expect(coordinate.is_after_middle?(2)).to be false
      expect(coordinate.is_after_middle?(3)).to be true
      expect(coordinate.is_after_middle?(4)).to be true
      expect(coordinate.is_after_middle?(5)).to be true
    end
    
    it 'should make coordinates positive correctly' do
      expect(Coordinate.canonicalize(-6, n)).to be 0
      expect(Coordinate.canonicalize(-5, n)).to be 1
      expect(Coordinate.canonicalize(-4, n)).to be 2
      expect(Coordinate.canonicalize(-3, n)).to be 3
      expect(Coordinate.canonicalize(-2, n)).to be 4
      expect(Coordinate.canonicalize(-1, n)).to be 5
      expect(Coordinate.canonicalize(0, n)).to be 0
      expect(Coordinate.canonicalize(1, n)).to be 1
      expect(Coordinate.canonicalize(2, n)).to be 2
      expect(Coordinate.canonicalize(3, n)).to be 3
      expect(Coordinate.canonicalize(4, n)).to be 4
      expect(Coordinate.canonicalize(5, n)).to be 5
    end

    it 'should return the right last before middle' do
      expect(Coordinate.last_before_middle(n)).to be 2
    end
    
    it 'should return the right middle or before' do
      expect(Coordinate.middle_or_before(n)).to be 2
    end
    
    it 'should raise for getting the middle' do
      expect { Coordinate.middle(n) }.to raise_error(ArgumentError)
    end

    it 'should return the right middle or after' do
      expect(Coordinate.middle_or_after(n)).to be 3
    end

    it 'should return the right highest coordinate' do
      expect(Coordinate.highest_coordinate(n)).to be 5
    end
    
    it 'should invert coordinates correctly' do
      expect(Coordinate.invert_coordinate(0, n)).to be 5
      expect(Coordinate.invert_coordinate(1, n)).to be 4
      expect(Coordinate.invert_coordinate(2, n)).to be 3
      expect(Coordinate.invert_coordinate(3, n)).to be 2
      expect(Coordinate.invert_coordinate(4, n)).to be 1
      expect(Coordinate.invert_coordinate(5, n)).to be 0
    end
    
    it 'should do the right thing for a corner' do
      expect(Coordinate.from_indices(Face::U, n, 0, 0).rotations).to be == [Coordinate.from_indices(Face::U, n, 0, 0), Coordinate.from_indices(Face::U, n, 0, -1), Coordinate.from_indices(Face::U, n, -1, -1), Coordinate.from_indices(Face::U, n, -1, 0)]
    end
    
    it 'should do the right thing for a wing' do
      expect(Coordinate.from_indices(Face::U, n, 0, 2).rotations).to be == [Coordinate.from_indices(Face::U, n, 0, 2), Coordinate.from_indices(Face::U, n, 2, -1), Coordinate.from_indices(Face::U, n, -1, -3), Coordinate.from_indices(Face::U, n, -3, 0)]
    end

    it 'should do the right thing for an oblique' do
      expect(Coordinate.from_indices(Face::U, n, 1, 2).rotations).to be == [Coordinate.from_indices(Face::U, n, 1, 2), Coordinate.from_indices(Face::U, n, 2, -2), Coordinate.from_indices(Face::U, n, -2, -3), Coordinate.from_indices(Face::U, n, -3, 1)]
    end
  end
end
