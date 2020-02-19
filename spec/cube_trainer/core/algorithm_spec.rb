# frozen_string_literal: true

require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'

RSpec::Matchers.define :cancel_moves do |cube_size, metric, expected|
  match do |actual|
    raise ArgumentError unless actual.length == 2

    actual[0].cancellations(actual[1], cube_size, metric) == expected &&
      actual[1].inverse.cancellations(actual[0].inverse, cube_size, metric) == expected
  end

  failure_message do |actual|
    "expected that #{actual[0]} + #{actual[1]} would cancel #{expected} moves #{metric} on " \
    "#{cube_size}x#{cube_size} cubes. Got #{actual[0].cancellations(actual[1], cube_size, metric)}"
  end
end

describe Core::Algorithm do
  include Core

  let(:cube_size) { 3 }

  it 'should invert algorithms correctly' do
    expect(parse_algorithm('R U').inverse).to be == parse_algorithm("U' R'")
  end

  it 'should compute the move count of algorithms correctly' do
    algorithm = parse_algorithm("R2 U F' S M2 E'")
    expect(algorithm.move_count(cube_size)).to be == 9
    expect(algorithm.move_count(cube_size, :htm)).to be == 9
    expect(algorithm.move_count(cube_size, :qtm)).to be == 12
    expect(algorithm.move_count(cube_size, :stm)).to be == 6
    expect(algorithm.move_count(cube_size, :qstm)).to be == 8
    expect(algorithm.move_count(cube_size, :sqtm)).to be == 8
  end

  it 'should compute cancellations of single moves correctly' do
    expect([parse_algorithm('R2'), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("R'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R'), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('U'), parse_algorithm('U2')]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'should compute cancellations of single wide moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm('l')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('l')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'should compute cancellations of single M moves correctly' do
    expect([parse_algorithm('R2'), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('M')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('R'), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("R'"), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("R'"), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('R2'), parse_algorithm('M')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('R2'), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 0)

    expect([parse_algorithm('M2'), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("M'"), parse_algorithm('R')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('M'), parse_algorithm('R')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('M2'), parse_algorithm('R')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M2'"), parse_algorithm("R'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M'"), parse_algorithm("R'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('M'), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('R2')]).to cancel_moves(cube_size, :htm, 0)

    expect([parse_algorithm('L2'), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("L'"), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("L'"), parse_algorithm('M')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("L'"), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('L'), parse_algorithm('M2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('L'), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('L2'), parse_algorithm('M')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('L2'), parse_algorithm("M'")]).to cancel_moves(cube_size, :htm, 0)

    expect([parse_algorithm('M2'), parse_algorithm('L2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("M'"), parse_algorithm("L'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('M'), parse_algorithm("L'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('M2'), parse_algorithm("L'")]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M2'"), parse_algorithm('L')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('L')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm('M'), parse_algorithm('L2')]).to cancel_moves(cube_size, :htm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('L2')]).to cancel_moves(cube_size, :htm, 0)
  end

  it 'should compute cancellations of moves across easy rotations correctly' do
    expect([parse_algorithm('R2'), parse_algorithm('x R2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("x' R'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('x R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R'), parse_algorithm('x R2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("x' R2")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("x R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('x R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("x R'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'should compute cancellations of moves across hard rotations correctly' do
    expect([parse_algorithm('R2 x'), parse_algorithm('y F2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("y F'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("R x'"), parse_algorithm('y F')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R'), parse_algorithm('y F2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("y' B2")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("y' B'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("y' B")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("y' B'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'should compute cancellations of algorithms correctly' do
    expect([parse_algorithm('R U'), parse_algorithm("U' R'")]).to cancel_moves(cube_size, :htm, 4)
    expect([parse_algorithm('R U'), parse_algorithm("U' R")]).to cancel_moves(cube_size, :htm, 3)
    expect([parse_algorithm('R U'), parse_algorithm("U R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R U2'), parse_algorithm("U2 R'")]).to cancel_moves(cube_size, :htm, 4)
  end

  it 'should compute cancellations of cancelling algorithms correctly' do
    expect([parse_algorithm('R R U'), parse_algorithm("U U2 R' R'")]).to cancel_moves(cube_size, :htm, 4)
  end

  it 'should compute cancellations of algorithms correctly if stuff has to be swapped around' do
    expect([parse_algorithm('D U'), parse_algorithm("D'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('D U'), parse_algorithm("D' U'")]).to cancel_moves(cube_size, :htm, 4)
    expect([parse_algorithm("D U R'"), parse_algorithm("R D' U'")]).to cancel_moves(cube_size, :htm, 6)
    expect([parse_algorithm("D U R' L"), parse_algorithm("R L' D' U'")]).to cancel_moves(cube_size, :htm, 8)
  end

  it 'should compute cancellations of algorithms across easy rotations correctly' do
    expect([parse_algorithm('R x U y L'), parse_algorithm("z U' R F")]).to cancel_moves(cube_size, :htm, 3)
  end

  it 'should compute cancellations of slice moves correctly' do
    expect([parse_algorithm('r2'), parse_algorithm('r')]).to cancel_moves(5, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm("r'")]).to cancel_moves(5, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm("r'")]).to cancel_moves(4, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm('r2')]).to cancel_moves(5, :qstm, 4)
    expect([parse_algorithm('r2'), parse_algorithm('l2')]).to cancel_moves(5, :qstm, 0)
  end

  it 'should compute cancellations of same fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('Rw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('3Rw'), parse_algorithm('3Rw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('3Rw'), parse_algorithm("3Rw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('3Rw'), parse_algorithm('3Rw2')]).to cancel_moves(5, :stm, 1)
  end

  it 'should compute cancellations of one slice away fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("R'")]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('Rw'), parse_algorithm("3Rw'")]).to cancel_moves(5, :stm, 1)
  end

  it 'should compute cancellations of non-fitting one slice away fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('R')]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm('3Rw2')]).to cancel_moves(5, :stm, 0)
  end

  it 'should compute cancellations of one fat M-slice away fat block fat moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm("3Rw'")]).to cancel_moves(4, :stm, 1)
  end

  it 'should compute cancellations of non-fitting one fat M-slice away fat block fat moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm('3Rw')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm('3Rw2')]).to cancel_moves(4, :stm, 0)
  end

  it 'should compute cancellations of non-fitting same fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('R')]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('3Rw'), parse_algorithm('Rw')]).to cancel_moves(5, :stm, 0)
  end

  it 'should compute cancellations of opposite fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("3Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('R'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('R'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('Rw'), parse_algorithm('3Lw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('R'), parse_algorithm('4Lw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('Rw'), parse_algorithm('3Lw2')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('R'), parse_algorithm('4Lw2')]).to cancel_moves(5, :stm, 1)
  end

  it 'should compute cancellations of non-fitting opposite fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("L'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm("Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("L'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("3Lw'")]).to cancel_moves(5, :stm, 0)
  end

  it 'should compute cancellations of fat M-slice moves with fat moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("Rw'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('3Rw'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("3Rw'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm('L'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("L'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm('Lw'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("Lw'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('3Lw'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("3Lw'"), parse_algorithm("M'")]).to cancel_moves(4, :stm, 0)

    expect([parse_algorithm("M'"), parse_algorithm('R')]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("M'"), parse_algorithm("R'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('Rw')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm("Rw'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('3Rw')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm("3Rw'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("M'"), parse_algorithm('L')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm("L'")]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("M'"), parse_algorithm('Lw')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm("Lw'")]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm("M'"), parse_algorithm('3Lw')]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm("M'"), parse_algorithm("3Lw'")]).to cancel_moves(4, :stm, 0)
  end

  it 'should compute cancellations of slice moves with fat moves correctly' do
    expect([parse_algorithm('r2'), parse_algorithm('Rw')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r2'), parse_algorithm('R')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm('R')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('r'), parse_algorithm("R'")]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm('Rw')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm("Rw'")]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('r'), parse_algorithm('3Rw')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm("3Rw'")]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm('2Lw')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm("2Lw'")]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm('3Lw')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('r'), parse_algorithm("3Lw'")]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('r'), parse_algorithm('4Lw')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('r'), parse_algorithm("4Lw'")]).to cancel_moves(5, :qtm, 0)

    expect([parse_algorithm('Rw'), parse_algorithm('r2')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('R'), parse_algorithm('r2')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('R'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm("R'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm("Rw'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('3Rw'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm("3Rw'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('2Lw'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm("2Lw'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm('3Lw'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
    expect([parse_algorithm("3Lw'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm('4Lw'), parse_algorithm('r')]).to cancel_moves(5, :qtm, 2)
    expect([parse_algorithm("4Lw'"), parse_algorithm('r')]).to cancel_moves(5, :qtm, 0)
  end

  it 'should compute cancellations of slice moves to a fat M-slice move correctly' do
    expect([parse_algorithm('r2'), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 2)
    expect([parse_algorithm('r'), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 1)
    expect([parse_algorithm('r'), parse_algorithm('l')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r'), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm("r'"), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm("r'"), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r2'), parse_algorithm('l')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r2'), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 0)
  end

  it 'should compute cancellations of fat M-slice moves correctly' do
    expect([parse_algorithm('M'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 2)
    expect([parse_algorithm('M'), parse_algorithm('M')]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm('M'), parse_algorithm('S')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('M'), parse_algorithm("S'")]).to cancel_moves(4, :stm, 0)
  end

  it 'should compute cancellations of rotations correctly' do
    expect([parse_algorithm('x'), parse_algorithm('x')]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm("x'")]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm('y')]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm('z')]).to cancel_moves(3, :htm, 0)
  end

  it 'should mirror algorithms correctly' do
    expect(parse_algorithm("M' D D2 F2 D2 F2").mirror(Core::Face::D)).to be == parse_algorithm("M U' U2 F2 U2 F2")
    expect(parse_algorithm('2u 2f').mirror(Core::Face::D)).to be == parse_algorithm("2d' 2f'")
  end

  it 'should apply a rotation correctly to Sarahs skewb algorithm' do
    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move('y'))).to be == parse_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move('y'))).to be == parse_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move('y'))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move('y'))).to be == parse_sarahs_skewb_algorithm("F R'")

    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move('y2'))).to be == parse_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move('y2'))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move('y2'))).to be == parse_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move('y2'))).to be == parse_sarahs_skewb_algorithm("L F'")

    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("B L'")
  end

  it 'should mirror Sarahs skewb algorithms correctly' do
    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Core::Face::R)).to be == parse_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Core::Face::R)).to be == parse_sarahs_skewb_algorithm("F' L")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Core::Face::R)).to be == parse_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Core::Face::R)).to be == parse_sarahs_skewb_algorithm("B' R")

    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Core::Face::F)).to be == parse_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Core::Face::F)).to be == parse_sarahs_skewb_algorithm("B' R")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Core::Face::F)).to be == parse_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Core::Face::F)).to be == parse_sarahs_skewb_algorithm("F' L")
  end
end
