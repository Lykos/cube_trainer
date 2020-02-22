# frozen_string_literal: true

require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube'

describe Core::Coordinate do
  include Core

  let(:coordinate) { described_class.from_indices(Core::Face::U, n, 0, 1) }

  context 'for an uneven n' do
    let(:n) { 7 }

    it 'checks equivalence of coordinates appropriately' do
      # rubocop:disable Lint/UselessComparison
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, 0)).to be(true)
      # rubocop:enable Lint/UselessComparison
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, -7)).to be(true)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::D, n, 1, 0)).to be(false)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, -1)).to be(false)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n + 2, 1, 0)).to be(false)
    end

    it 'returns the values passed in the constructor via the getters' do
      expect(coordinate.face).to eq(Core::Face::U)
      expect(coordinate.cube_size).to eq(n)
      expect(coordinate.x).to eq(0)
      expect(coordinate.y).to eq(1)
    end

    it 'checks coordinates appropriately' do
      expect { described_class.from_indices(Core::Face::U, n, 0, 1.0) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, -7) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, -8) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, 7) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, 0) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, 5) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, 6) }.not_to(raise_error)
    end

    it 'checks whether something is before the middle' do
      expect(coordinate.before_middle?(-7)).to be(true)
      expect(coordinate.before_middle?(-6)).to be(true)
      expect(coordinate.before_middle?(-5)).to be(true)
      expect(coordinate.before_middle?(-4)).to be(false)
      expect(coordinate.before_middle?(-3)).to be(false)
      expect(coordinate.before_middle?(-2)).to be(false)
      expect(coordinate.before_middle?(-1)).to be(false)
      expect(coordinate.before_middle?(0)).to be(true)
      expect(coordinate.before_middle?(1)).to be(true)
      expect(coordinate.before_middle?(2)).to be(true)
      expect(coordinate.before_middle?(3)).to be(false)
      expect(coordinate.before_middle?(4)).to be(false)
      expect(coordinate.before_middle?(5)).to be(false)
      expect(coordinate.before_middle?(6)).to be(false)
    end

    it 'checks whether something is after the middle' do
      expect(coordinate.after_middle?(-7)).to be(false)
      expect(coordinate.after_middle?(-6)).to be(false)
      expect(coordinate.after_middle?(-5)).to be(false)
      expect(coordinate.after_middle?(-4)).to be(false)
      expect(coordinate.after_middle?(-3)).to be(true)
      expect(coordinate.after_middle?(-2)).to be(true)
      expect(coordinate.after_middle?(-1)).to be(true)
      expect(coordinate.after_middle?(0)).to be(false)
      expect(coordinate.after_middle?(1)).to be(false)
      expect(coordinate.after_middle?(2)).to be(false)
      expect(coordinate.after_middle?(3)).to be(false)
      expect(coordinate.after_middle?(4)).to be(true)
      expect(coordinate.after_middle?(5)).to be(true)
      expect(coordinate.after_middle?(6)).to be(true)
    end

    it 'makes coordinates positive correctly' do
      expect(described_class.canonicalize(-7, n)).to be(0)
      expect(described_class.canonicalize(-6, n)).to be(1)
      expect(described_class.canonicalize(-5, n)).to be(2)
      expect(described_class.canonicalize(-4, n)).to be(3)
      expect(described_class.canonicalize(-3, n)).to be(4)
      expect(described_class.canonicalize(-2, n)).to be(5)
      expect(described_class.canonicalize(-1, n)).to be(6)
      expect(described_class.canonicalize(0, n)).to be(0)
      expect(described_class.canonicalize(1, n)).to be(1)
      expect(described_class.canonicalize(2, n)).to be(2)
      expect(described_class.canonicalize(3, n)).to be(3)
      expect(described_class.canonicalize(4, n)).to be(4)
      expect(described_class.canonicalize(5, n)).to be(5)
      expect(described_class.canonicalize(6, n)).to be(6)
    end

    it 'returns the right last before middle' do
      expect(described_class.last_before_middle(n)).to be(2)
    end

    it 'returns the right middle or before' do
      expect(described_class.middle_or_before(n)).to be(3)
    end

    it 'returns the right middle' do
      expect(described_class.middle(n)).to be(3)
    end

    it 'returns the right middle or after' do
      expect(described_class.middle_or_after(n)).to be(3)
    end

    it 'returns the right highest coordinate' do
      expect(described_class.highest_coordinate(n)).to be(6)
    end

    it 'inverts coordinates correctly' do
      expect(described_class.invert_coordinate(0, n)).to be(6)
      expect(described_class.invert_coordinate(1, n)).to be(5)
      expect(described_class.invert_coordinate(2, n)).to be(4)
      expect(described_class.invert_coordinate(3, n)).to be(3)
      expect(described_class.invert_coordinate(4, n)).to be(2)
      expect(described_class.invert_coordinate(5, n)).to be(1)
      expect(described_class.invert_coordinate(6, n)).to be(0)
    end

    it 'does the right thing for a corner' do
      expect(described_class.from_indices(Core::Face::U, n, 0, 0).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, 0), described_class.from_indices(Core::Face::U, n, 0, -1), described_class.from_indices(Core::Face::U, n, -1, -1), described_class.from_indices(Core::Face::U, n, -1, 0))
    end

    it 'does the right thing for a wing' do
      expect(described_class.from_indices(Core::Face::U, n, 0, 2).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, 2), described_class.from_indices(Core::Face::U, n, 2, -1), described_class.from_indices(Core::Face::U, n, -1, -3), described_class.from_indices(Core::Face::U, n, -3, 0))
    end

    it 'does the right thing for a midge' do
      expect(described_class.from_indices(Core::Face::U, n, 0, 3).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, 3), described_class.from_indices(Core::Face::U, n, 3, -1), described_class.from_indices(Core::Face::U, n, -1, -4), described_class.from_indices(Core::Face::U, n, -4, 0))
    end

    it 'does the right thing for an oblique' do
      expect(described_class.from_indices(Core::Face::U, n, 1, 2).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 1, 2), described_class.from_indices(Core::Face::U, n, 2, -2), described_class.from_indices(Core::Face::U, n, -2, -3), described_class.from_indices(Core::Face::U, n, -3, 1))
    end
  end

  context 'for an even n' do
    let(:n) { 6 }

    it 'checks equivalence of coordinates appropriately' do
      # rubocop:disable Lint/UselessComparison
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, 0)).to be(true)
      # rubocop:enable Lint/UselessComparison
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, -6)).to be(true)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::D, n, 1, 0)).to be(false)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n, 1, -1)).to be(false)
      expect(described_class.from_indices(Core::Face::U, n, 1, 0) ==
             described_class.from_indices(Core::Face::U, n + 2, 1, 0)).to be(false)
    end

    it 'checks coordinates appropriately' do
      expect { described_class.from_indices(Core::Face::U, n, 0, 1.0) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, -6) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, -7) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, 6) }.to raise_error(ArgumentError)
      expect { described_class.from_indices(Core::Face::U, n, 0, 0) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, 4) }.not_to(raise_error)
      expect { described_class.from_indices(Core::Face::U, n, 0, 5) }.not_to(raise_error)
    end

    it 'returns the values passed in the constructor via the getters' do
      expect(coordinate.face).to be == Core::Face::U
      expect(coordinate.cube_size).to be == n
      expect(coordinate.x).to be == 0
      expect(coordinate.y).to be == 1
    end

    it 'checks whether something is before the middle' do
      expect(coordinate.before_middle?(-6)).to be(true)
      expect(coordinate.before_middle?(-5)).to be(true)
      expect(coordinate.before_middle?(-4)).to be(true)
      expect(coordinate.before_middle?(-3)).to be(false)
      expect(coordinate.before_middle?(-2)).to be(false)
      expect(coordinate.before_middle?(-1)).to be(false)
      expect(coordinate.before_middle?(0)).to be(true)
      expect(coordinate.before_middle?(1)).to be(true)
      expect(coordinate.before_middle?(2)).to be(true)
      expect(coordinate.before_middle?(3)).to be(false)
      expect(coordinate.before_middle?(4)).to be(false)
      expect(coordinate.before_middle?(5)).to be(false)
    end

    it 'checks whether something is after the middle' do
      expect(coordinate.after_middle?(-6)).to be(false)
      expect(coordinate.after_middle?(-5)).to be(false)
      expect(coordinate.after_middle?(-4)).to be(false)
      expect(coordinate.after_middle?(-3)).to be(true)
      expect(coordinate.after_middle?(-2)).to be(true)
      expect(coordinate.after_middle?(-1)).to be(true)
      expect(coordinate.after_middle?(0)).to be(false)
      expect(coordinate.after_middle?(1)).to be(false)
      expect(coordinate.after_middle?(2)).to be(false)
      expect(coordinate.after_middle?(3)).to be(true)
      expect(coordinate.after_middle?(4)).to be(true)
      expect(coordinate.after_middle?(5)).to be(true)
    end

    it 'makes coordinates positive correctly' do
      expect(described_class.canonicalize(-6, n)).to be(0)
      expect(described_class.canonicalize(-5, n)).to be(1)
      expect(described_class.canonicalize(-4, n)).to be(2)
      expect(described_class.canonicalize(-3, n)).to be(3)
      expect(described_class.canonicalize(-2, n)).to be(4)
      expect(described_class.canonicalize(-1, n)).to be(5)
      expect(described_class.canonicalize(0, n)).to be(0)
      expect(described_class.canonicalize(1, n)).to be(1)
      expect(described_class.canonicalize(2, n)).to be(2)
      expect(described_class.canonicalize(3, n)).to be(3)
      expect(described_class.canonicalize(4, n)).to be(4)
      expect(described_class.canonicalize(5, n)).to be(5)
    end

    it 'returns the right last before middle' do
      expect(described_class.last_before_middle(n)).to be(2)
    end

    it 'returns the right middle or before' do
      expect(described_class.middle_or_before(n)).to be(2)
    end

    it 'raises for getting the middle' do
      expect { described_class.middle(n) }.to raise_error(ArgumentError)
    end

    it 'returns the right middle or after' do
      expect(described_class.middle_or_after(n)).to be(3)
    end

    it 'returns the right highest coordinate' do
      expect(described_class.highest_coordinate(n)).to be(5)
    end

    it 'inverts coordinates correctly' do
      expect(described_class.invert_coordinate(0, n)).to be(5)
      expect(described_class.invert_coordinate(1, n)).to be(4)
      expect(described_class.invert_coordinate(2, n)).to be(3)
      expect(described_class.invert_coordinate(3, n)).to be(2)
      expect(described_class.invert_coordinate(4, n)).to be(1)
      expect(described_class.invert_coordinate(5, n)).to be(0)
    end

    it 'gets the right rotations for a corner' do
      expect(described_class.from_indices(Core::Face::U, n, 0, 0).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, 0), described_class.from_indices(Core::Face::U, n, 0, -1), described_class.from_indices(Core::Face::U, n, -1, -1), described_class.from_indices(Core::Face::U, n, -1, 0))
    end

    it 'gets the right rotations for a wing' do
      expect(described_class.from_indices(Core::Face::U, n, 0, 2).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, 2), described_class.from_indices(Core::Face::U, n, 2, -1), described_class.from_indices(Core::Face::U, n, -1, -3), described_class.from_indices(Core::Face::U, n, -3, 0))
    end

    it 'gets the right rotations for an oblique' do
      expect(described_class.from_indices(Core::Face::U, n, 1, 2).rotations).to contain_exactly(described_class.from_indices(Core::Face::U, n, 1, 2), described_class.from_indices(Core::Face::U, n, 2, -2), described_class.from_indices(Core::Face::U, n, -2, -3), described_class.from_indices(Core::Face::U, n, -3, 1))
    end

    it 'gets the right solved position for wing FU' do
      part = Core::Wing.for_face_symbols(%i[F U])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::F, n, 0, 1)
    end

    it 'gets the right solved position for wing UF' do
      part = Core::Wing.for_face_symbols(%i[U F])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::U, n, 0, n - 2)
    end

    it 'gets the right solved position for wing BD' do
      part = Core::Wing.for_face_symbols(%i[B D])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::B, n, n - 1, 1)
    end

    it 'gets the right solved position for wing DB' do
      part = Core::Wing.for_face_symbols(%i[D B])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::D, n, n - 1, n - 2)
    end

    it 'gets the right solved position for wing LB' do
      part = Core::Wing.for_face_symbols(%i[L B])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::L, n, 1, n - 1)
    end

    it 'gets the right solved position for wing BL' do
      part = Core::Wing.for_face_symbols(%i[B L])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::B, n, n - 2, n - 1)
    end

    it 'gets the right solved position for wing RB' do
      part = Core::Wing.for_face_symbols(%i[R B])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::R, n, n - 2, n - 1)
    end

    it 'gets the right solved position for wing BR' do
      part = Core::Wing.for_face_symbols(%i[B R])
      expect(described_class.solved_position(part, n, 0)).to eq_cube_coordinate(Core::Face::B, n, 1, 0)
    end

    it 'gets the right solved positions for wing FU' do
      part = Core::Wing.for_face_symbols(%i[F U])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::F, n, 0, 1), described_class.from_indices(Core::Face::U, n, 0, 1))
    end

    it 'gets the right solved positions for wing UF' do
      part = Core::Wing.for_face_symbols(%i[U F])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::U, n, 0, n - 2), described_class.from_indices(Core::Face::F, n, 0, n - 2))
    end

    it 'gets the right solved positions for wing BD' do
      part = Core::Wing.for_face_symbols(%i[B D])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::B, n, n - 1, 1), described_class.from_indices(Core::Face::D, n, n - 1, 1))
    end

    it 'gets the right solved positions for wing DB' do
      part = Core::Wing.for_face_symbols(%i[D B])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::D, n, n - 1, n - 2), described_class.from_indices(Core::Face::B, n, n - 1, n - 2))
    end

    it 'gets the right solved positions for wing LB' do
      part = Core::Wing.for_face_symbols(%i[L B])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::L, n, 1, n - 1), described_class.from_indices(Core::Face::B, n, 1, n - 1))
    end

    it 'gets the right solved positions for wing BL' do
      part = Core::Wing.for_face_symbols(%i[B L])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::B, n, n - 2, n - 1), described_class.from_indices(Core::Face::L, n, n - 2, n - 1))
    end

    it 'gets the right solved positions for wing RB' do
      part = Core::Wing.for_face_symbols(%i[R B])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::R, n, n - 2, n - 1), described_class.from_indices(Core::Face::B, n, n - 2, 0))
    end

    it 'gets the right solved positions for wing BR' do
      part = Core::Wing.for_face_symbols(%i[B R])
      expect(described_class.solved_positions(part, n, 0)).to contain_exactly(described_class.from_indices(Core::Face::B, n, 1, 0), described_class.from_indices(Core::Face::R, n, 1, n - 1))
    end
  end
end
