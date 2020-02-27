# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/abstract_move'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

RSpec::Matchers.define(:cancel_moves) do |cube_size, metric, expected|
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

RSpec::Matchers.define(:have_length_at_most) do |expected|
  match do |actual|
    actual.length <= expected
  end

  failure_message do |actual|
    "expected that #{actual} would have length at most #{expected}"
  end
end

describe Core::Algorithm do
  include Core

  let(:cube_size) { 3 }
  let(:color_scheme) { ColorScheme::BERNHARD }

  it 'inverts algorithms correctly' do
    expect(parse_algorithm('R U').inverse).to eq_cube_algorithm("U' R'")
  end

  it 'computes the move count of algorithms correctly' do
    algorithm = parse_algorithm("R2 U F' S M2 E'")
    expect(algorithm.move_count(cube_size)).to eq(9)
    expect(algorithm.move_count(cube_size, :htm)).to eq(9)
    expect(algorithm.move_count(cube_size, :qtm)).to eq(12)
    expect(algorithm.move_count(cube_size, :stm)).to eq(6)
    expect(algorithm.move_count(cube_size, :qstm)).to eq(8)
    expect(algorithm.move_count(cube_size, :sqtm)).to eq(8)
  end

  it 'computes cancellations of single moves correctly' do
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

  it 'computes cancellations of single wide moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm('l')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm('l2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('l')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("l'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'computes cancellations of single M moves correctly' do
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

  it 'computes cancellations of moves across easy rotations correctly' do
    expect([parse_algorithm('R2'), parse_algorithm('x R2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("x' R'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm('x R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R'), parse_algorithm('x R2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("x' R2")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("x R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm('x R')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("x R'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'computes cancellations of moves across hard rotations correctly' do
    expect([parse_algorithm('R2 x'), parse_algorithm('y F2')]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('R'), parse_algorithm("y F'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm("R x'"), parse_algorithm('y F')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R'), parse_algorithm('y F2')]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("y' B2")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm("R'"), parse_algorithm("y' B'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("y' B")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R2'), parse_algorithm("y' B'")]).to cancel_moves(cube_size, :htm, 1)
  end

  it 'computes cancellations of algorithms correctly' do
    expect([parse_algorithm('R U'), parse_algorithm("U' R'")]).to cancel_moves(cube_size, :htm, 4)
    expect([parse_algorithm('R U'), parse_algorithm("U' R")]).to cancel_moves(cube_size, :htm, 3)
    expect([parse_algorithm('R U'), parse_algorithm("U R'")]).to cancel_moves(cube_size, :htm, 1)
    expect([parse_algorithm('R U2'), parse_algorithm("U2 R'")]).to cancel_moves(cube_size, :htm, 4)
  end

  it 'computes cancellations of cancelling algorithms correctly' do
    expect([parse_algorithm('R R U'), parse_algorithm("U U2 R' R'")]).to cancel_moves(cube_size, :htm, 4)
  end

  it 'computes cancellations of algorithms correctly if stuff has to be swapped around' do
    expect([parse_algorithm('D U'), parse_algorithm("D'")]).to cancel_moves(cube_size, :htm, 2)
    expect([parse_algorithm('D U'), parse_algorithm("D' U'")]).to cancel_moves(cube_size, :htm, 4)
    expect([parse_algorithm("D U R'"), parse_algorithm("R D' U'")]).to cancel_moves(cube_size, :htm, 6)
    expect([parse_algorithm("D U R' L"), parse_algorithm("R L' D' U'")]).to cancel_moves(cube_size, :htm, 8)
  end

  it 'computes cancellations of algorithms across easy rotations correctly' do
    expect([parse_algorithm('R x U y L'), parse_algorithm("z U' R F")]).to cancel_moves(cube_size, :htm, 3)
  end

  it 'computes cancellations of slice moves correctly' do
    expect([parse_algorithm('r2'), parse_algorithm('r')]).to cancel_moves(5, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm("r'")]).to cancel_moves(5, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm("r'")]).to cancel_moves(4, :qstm, 2)
    expect([parse_algorithm('r2'), parse_algorithm('r2')]).to cancel_moves(5, :qstm, 4)
    expect([parse_algorithm('r2'), parse_algorithm('l2')]).to cancel_moves(5, :qstm, 0)
  end

  it 'computes cancellations of same fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('Rw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('3Rw'), parse_algorithm('3Rw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('3Rw'), parse_algorithm("3Rw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('3Rw'), parse_algorithm('3Rw2')]).to cancel_moves(5, :stm, 1)
  end

  it 'computes cancellations of one slice away fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("R'")]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('Rw'), parse_algorithm("3Rw'")]).to cancel_moves(5, :stm, 1)
  end

  it 'computes cancellations of non-fitting one slice away fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('R')]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm('3Rw2')]).to cancel_moves(5, :stm, 0)
  end

  it 'computes cancellations of one fat M-slice away fat block fat moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm("3Rw'")]).to cancel_moves(4, :stm, 1)
  end

  it 'computes cancellations of non-fitting one fat M-slice away fat block fat moves correctly' do
    expect([parse_algorithm('R'), parse_algorithm('3Rw')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm('3Rw2')]).to cancel_moves(4, :stm, 0)
  end

  it 'computes cancellations of non-fitting same fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm('R')]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('3Rw'), parse_algorithm('Rw')]).to cancel_moves(5, :stm, 0)
  end

  it 'computes cancellations of opposite fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("3Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('R'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('R'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 2)
    expect([parse_algorithm('Rw'), parse_algorithm('3Lw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('R'), parse_algorithm('4Lw')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('Rw'), parse_algorithm('3Lw2')]).to cancel_moves(5, :stm, 1)
    expect([parse_algorithm('R'), parse_algorithm('4Lw2')]).to cancel_moves(5, :stm, 1)
  end

  it 'computes cancellations of non-fitting opposite fat block fat moves correctly' do
    expect([parse_algorithm('Rw'), parse_algorithm("L'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm("Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('Rw'), parse_algorithm("4Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("L'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("Lw'")]).to cancel_moves(5, :stm, 0)
    expect([parse_algorithm('R'), parse_algorithm("3Lw'")]).to cancel_moves(5, :stm, 0)
  end

  it 'computes cancellations of fat M-slice moves with fat moves correctly' do
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

  it 'computes cancellations of slice moves with fat moves correctly' do
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

  it 'computes cancellations of slice moves to a fat M-slice move correctly' do
    expect([parse_algorithm('r2'), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 2)
    expect([parse_algorithm('r'), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 1)
    expect([parse_algorithm('r'), parse_algorithm('l')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r'), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm("r'"), parse_algorithm('l2')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm("r'"), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r2'), parse_algorithm('l')]).to cancel_moves(4, :qstm, 0)
    expect([parse_algorithm('r2'), parse_algorithm("l'")]).to cancel_moves(4, :qstm, 0)
  end

  it 'computes cancellations of fat M-slice moves correctly' do
    expect([parse_algorithm('M'), parse_algorithm("M'")]).to cancel_moves(4, :stm, 2)
    expect([parse_algorithm('M'), parse_algorithm('M')]).to cancel_moves(4, :stm, 1)
    expect([parse_algorithm('M'), parse_algorithm('S')]).to cancel_moves(4, :stm, 0)
    expect([parse_algorithm('M'), parse_algorithm("S'")]).to cancel_moves(4, :stm, 0)
  end

  it 'computes cancellations of rotations correctly' do
    expect([parse_algorithm('x'), parse_algorithm('x')]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm("x'")]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm('y')]).to cancel_moves(3, :htm, 0)
    expect([parse_algorithm('x'), parse_algorithm('z')]).to cancel_moves(3, :htm, 0)
  end

  it 'cancels rotations correctly' do
    expect(parse_algorithm('x x').cancelled(3)).to eq_cube_algorithm('x2')
    expect(parse_algorithm('x2 y2').cancelled(3)).to eq_cube_algorithm('z2')
    expect(parse_algorithm('x y x').cancelled(3)).to eq_cube_algorithm('z x2')
    expect(parse_algorithm("x x'").cancelled(3)).to eq_cube_algorithm('')
    expect(parse_algorithm('x y').cancelled(3)).to eq_cube_algorithm('x y')
    expect(parse_algorithm('x z').cancelled(3)).to eq_cube_algorithm('x z')
  end

  it "doesn't change meaning after cancellation" do
    alg = parse_algorithm("F b D2 F")
    expect(alg.cancelled(cube_size)).to equivalent_cube_algorithm(alg, cube_size, color_scheme)
  end

  it "doesn't change meaning after cancellation" do
    alg = parse_algorithm("L2 U' R2 l D' x2")
    expect(alg.cancelled(cube_size)).to equivalent_cube_algorithm(alg, cube_size, color_scheme)
  end

  it "cancellations don't exceed the sum of move counts" do
    left = parse_algorithm("M' L2 y R' L R2")
    right = parse_algorithm("U2 B x2 F' Dw2 Dw2")
    move_count_sum = left.move_count(cube_size, :qstm) + right.move_count(cube_size, :qstm)
    expect(left.cancellations(right, cube_size, :qstm)).to be <= move_count_sum
  end

  shared_examples 'correct cancellation algorithm' do |cube_size|
    it 'applies a rotation correctly to an algorithm' do
      property_of do
        Rantly { Tuple.new([cube_algorithm(cube_size), rotation]) }
      end.check do |tuple|
        alg, rotation = tuple.array
        modified_alg = Core::Algorithm.move(rotation.inverse) + alg + Core::Algorithm.move(rotation)
        expect(alg.rotate_by(rotation)).to equivalent_cube_algorithm(modified_alg, cube_size, color_scheme)
      end
    end

    it "doesn't change meaning after cancellation" do
      property_of do
        Rantly { cube_algorithm(cube_size) }
      end.check do |alg|
        expect(alg.cancelled(cube_size)).to equivalent_cube_algorithm(alg, cube_size, color_scheme)
      end
    end
 
    it "doesn't change meaning after cancellation of rotations" do
      property_of do
        Rantly { rotations }
      end.check do |alg|
        expect(alg.cancelled(cube_size)).to equivalent_cube_algorithm(alg, cube_size, color_scheme)
      end
    end
 
    it "doesn't increase in length after cancellation" do
      property_of do
        Rantly { Tuple.new([cube_algorithm(cube_size), move_metric]) }
      end.check do |tuple|
        alg, move_metric = tuple.array
        expect(alg.cancelled(cube_size).move_count(cube_size, move_metric)).to be <= alg.move_count(cube_size, move_metric)
      end
    end

    it "cancellations don't exceed the sum of move counts" do
      property_of do
        Rantly { Tuple.new([cube_algorithm(cube_size), cube_algorithm(cube_size), move_metric]) }
      end.check do |tuple|
        left, right, move_metric = tuple.array
        move_count_sum = left.move_count(cube_size, move_metric) + right.move_count(cube_size, move_metric)
        expect(left.cancellations(right, cube_size, move_metric)).to be <= move_count_sum
      end
    end

    it 'can always reduce rotations to two rotations' do
      property_of do
        rotations
      end.check do |alg|
        # Technically 3 is possible, but our implementation achieves 2.
        # TODO Improve it to 2.
        expect(alg.cancelled(cube_size)).to have_length_at_most(3)
      end
    end
  end

  it_behaves_like 'correct cancellation algorithm', 2
  it_behaves_like 'correct cancellation algorithm', 3
  it_behaves_like 'correct cancellation algorithm', 4

  it 'mirrors algorithms correctly' do
    expect(parse_algorithm("M' D D2 F2 D2 F2").mirror(Core::Face::D)).to eq_cube_algorithm("M U' U2 F2 U2 F2")
    expect(parse_algorithm('2u 2f').mirror(Core::Face::D)).to eq_cube_algorithm("2d' 2f'")
  end

  it 'applies a rotation correctly to a skewb algorithm' do
    property_of do
      Rantly { Tuple.new([skewb_algorithm, rotation]) }
    end.check do |tuple|
      alg, rotation = tuple.array
      modified_alg = Core::Algorithm.move(rotation.inverse) + alg + Core::Algorithm.move(rotation)
      expect(alg.rotate_by(rotation)).to equivalent_skewb_algorithm(modified_alg, color_scheme)
    end
  end
  
  it "doesn't change meaning after cancellation of rotations" do
    property_of do
      Rantly { rotations }
    end.check do |alg|
      expect(alg.cancelled(cube_size)).to equivalent_skewb_algorithm(alg, color_scheme)
    end
  end
 
  it 'applies a rotation correctly to a simple Sarahs skewb algorithm' do
    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move('y'))).to eq_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move('y'))).to eq_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move('y'))).to eq_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move('y'))).to eq_sarahs_skewb_algorithm("F R'")

    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move('y2'))).to eq_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move('y2'))).to eq_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move('y2'))).to eq_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move('y2'))).to eq_sarahs_skewb_algorithm("L F'")

    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move("y'"))).to eq_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move("y'"))).to eq_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move("y'"))).to eq_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move("y'"))).to eq_sarahs_skewb_algorithm("B L'")
  end

  it 'mirrors Sarahs skewb algorithms correctly' do
    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Core::Face::R)).to eq_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Core::Face::R)).to eq_sarahs_skewb_algorithm("F' L")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Core::Face::R)).to eq_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Core::Face::R)).to eq_sarahs_skewb_algorithm("B' R")

    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Core::Face::F)).to eq_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Core::Face::F)).to eq_sarahs_skewb_algorithm("B' R")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Core::Face::F)).to eq_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Core::Face::F)).to eq_sarahs_skewb_algorithm("F' L")
  end
end
