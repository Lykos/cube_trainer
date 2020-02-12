# frozen_string_literal: true

require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/move'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/color_scheme'
require 'cube_trainer/core/part_cycle_factory'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

include CubeConstants
include CubePrintHelper

RSpec.shared_examples 'cube_state' do |cube_size|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cycle_factory) { PartCycleFactory.new(cube_size, 0) }

  def construct_cycle(part_type, letters)
    cycle_factory.construct(letters.map { |l| letter_scheme.for_letter(part_type, l) })
  end

  def expect_stickers_changed(cube_state, changed_parts)
    original_state = create_interesting_cube_state(cube_state.n)
    FACE_SYMBOLS.each do |s|
      cube_state.n.times do |x|
        cube_state.n.times do |y|
          coordinate = Coordinate.from_indices(Face.for_face_symbol(s), cube_state.n, x, y)
          expected_color = changed_parts[[s, x, y]] || original_state[coordinate]
          expect(cube_state[coordinate]).to be == expected_color
        end
      end
    end
  end

  def create_interesting_cube_state(cube_size)
    state = color_scheme.solved_cube_state(cube_size)
    # The state is like a r2 b2 to make turns a bit more interesting than solved faces.
    0.upto(cube_size - 1) do |a|
      state[Coordinate.from_indices(Face::D, cube_size, a, 1)] = :yellow
      state[Coordinate.from_indices(Face::D, cube_size, -2, a)] = :yellow
      state[Coordinate.from_indices(Face::U, cube_size, a, 1)] = :white
      state[Coordinate.from_indices(Face::U, cube_size, -2, a)] = :white
      state[Coordinate.from_indices(Face::F, cube_size, a, 1)] = :orange
      state[Coordinate.from_indices(Face::B, cube_size, a, 1)] = :red
      state[Coordinate.from_indices(Face::L, cube_size, a, -2)] = :green
      state[Coordinate.from_indices(Face::R, cube_size, a, -2)] = :blue
    end
    state[Coordinate.from_indices(Face::D, cube_size, -2, -2)] = :white
    state[Coordinate.from_indices(Face::U, cube_size, -2, -2)] = :yellow
    state
  end

  let(:cube_state) { create_interesting_cube_state(cube_size) }

  it 'should not be equal to a state with one sticker changed' do
    property_of do
      Rantly { cube_coordinate(cube_size) }
    end.check do |c|
      other_cube_state = cube_state.dup
      other_cube_state[c] = :other_color
      expect(other_cube_state == cube_state).to be_falsey
    end
  end

  it 'should have the right state after applying a nice corner commutator' do
    construct_cycle(Corner, %w[c d k]).apply_to(cube_state)
    changed_parts = {
      [:U, cube_size - 1, cube_size - 1] => :green,
      [:R, 0, cube_size - 1] => :orange,
      [:R, cube_size - 1, cube_size - 1] => :yellow,
      [:B, 0, 0] => :blue,
      [:B, 0, cube_size - 1] => :white,
      [:L, 0, cube_size - 1] => :orange,
      [:D, cube_size - 1, 0] => :green
    }
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a nasty corner commutator' do
    construct_cycle(Corner, %w[c h g]).apply_to(cube_state)
    changed_parts = {
      [:U, cube_size - 1, cube_size - 1] => :red,
      [:U, 0, cube_size - 1] => :blue,
      [:L, 0, 0] => :white,
      [:L, cube_size - 1, 0] => :orange,
      [:D, 0, cube_size - 1] => :blue,
      [:B, 0, cube_size - 1] => :yellow,
      [:F, cube_size - 1, cube_size - 1] => :yellow
    }
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a U move' do
    parse_algorithm('U').apply_to(cube_state)
    changed_parts = {
      [:F, 0, 1] => :blue,
      [:L, 0, 1] => :orange,
      [:B, 0, 1] => :green,
      [:R, 0, 1] => :red
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, 0, x]] ||= :green
      changed_parts[[:L, 0, x]] ||= :red
      changed_parts[[:B, 0, x]] ||= :blue
      changed_parts[[:R, 0, x]] ||= :orange
      if cube_size > 3
        changed_parts[[:U, 1, x]] ||= :white
        changed_parts[[:U, cube_size - 2, x]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a U' move" do
    parse_algorithm("U'").apply_to(cube_state)
    changed_parts = {
      [:F, 0, cube_size - 2] => :green,
      [:L, 0, cube_size - 2] => :red,
      [:B, 0, cube_size - 2] => :blue,
      [:R, 0, cube_size - 2] => :orange
    }
    if cube_size > 3
      changed_parts[[:U, 1, cube_size - 2]] = :yellow
      changed_parts[[:U, cube_size - 2, 1]] = :white
    end
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, 0, x]] ||= :blue
      changed_parts[[:L, 0, x]] ||= :orange
      changed_parts[[:B, 0, x]] ||= :green
      changed_parts[[:R, 0, x]] ||= :red
      if cube_size > 3
        changed_parts[[:U, x, 1]] ||= :yellow
        changed_parts[[:U, x, cube_size - 2]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a R move' do
    parse_algorithm('R').apply_to(cube_state)
    changed_parts = {
      [:F, cube_size - 2, 0] => :yellow,
      [:B, cube_size - 2, 0] => :white
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, x, 0]] ||= :red
      changed_parts[[:B, x, 0]] ||= :yellow
      changed_parts[[:D, x, 0]] ||= :orange
      changed_parts[[:F, x, 0]] ||= :white
      changed_parts[[:R, cube_size - 2, x]] = :blue
      changed_parts[[:R, x, cube_size - 2]] ||= :green
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a R' move" do
    parse_algorithm("R'").apply_to(cube_state)
    changed_parts = {
      [:F, 1, 0] => :white,
      [:B, 1, 0] => :yellow
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, x, 0]] ||= :orange
      changed_parts[[:B, x, 0]] ||= :white
      changed_parts[[:D, x, 0]] ||= :red
      changed_parts[[:F, x, 0]] ||= :yellow
      changed_parts[[:R, 1, x]] = :blue
      changed_parts[[:R, x, cube_size - 2]] ||= :green
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a F move' do
    parse_algorithm('F').apply_to(cube_state)
    changed_parts = {
      [:R, cube_size - 2, 0] => :white,
      [:L, cube_size - 2, 0] => :yellow
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, 0, x]] ||= :blue
      changed_parts[[:R, x, 0]] ||= :yellow
      changed_parts[[:D, 0, x]] ||= :green
      changed_parts[[:L, x, 0]] ||= :white
      changed_parts[[:F, cube_size - 2, x]] = :orange
      changed_parts[[:F, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a F' move" do
    parse_algorithm("F'").apply_to(cube_state)
    changed_parts = {
      [:R, 1, 0] => :yellow,
      [:L, 1, 0] => :white
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, 0, x]] ||= :green
      changed_parts[[:R, x, 0]] ||= :white
      changed_parts[[:D, 0, x]] ||= :blue
      changed_parts[[:L, x, 0]] ||= :yellow
      changed_parts[[:F, 1, x]] = :orange
      changed_parts[[:F, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a B move' do
    parse_algorithm('B').apply_to(cube_state)
    changed_parts = {
      [:R, 1, cube_size - 1] => :yellow,
      [:L, 1, cube_size - 1] => :white
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, cube_size - 1, x]] ||= :green
      changed_parts[[:R, x, cube_size - 1]] ||= :white
      changed_parts[[:D, cube_size - 1, x]] ||= :blue
      changed_parts[[:L, x, cube_size - 1]] ||= :yellow
      changed_parts[[:B, 1, x]] = :red
      changed_parts[[:B, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a B2 move' do
    parse_algorithm('B2').apply_to(cube_state)
    changed_parts = {
      [:U, cube_size - 1, cube_size - 2] => :yellow,
      [:D, cube_size - 1, cube_size - 2] => :white
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, cube_size - 1, x]] ||= :white
      changed_parts[[:R, x, cube_size - 1]] ||= :blue
      changed_parts[[:D, cube_size - 1, x]] ||= :yellow
      changed_parts[[:L, x, cube_size - 1]] ||= :green
      changed_parts[[:B, x, cube_size - 2]] = :red
      changed_parts[[:B, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a B' move" do
    parse_algorithm("B'").apply_to(cube_state)
    changed_parts = {
      [:R, cube_size - 2, cube_size - 1] => :white,
      [:L, cube_size - 2, cube_size - 1] => :yellow
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, cube_size - 1, x]] ||= :blue
      changed_parts[[:R, x, cube_size - 1]] ||= :yellow
      changed_parts[[:D, cube_size - 1, x]] ||= :green
      changed_parts[[:L, x, cube_size - 1]] ||= :white
      changed_parts[[:B, cube_size - 2, x]] = :red
      changed_parts[[:B, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a L move' do
    parse_algorithm('L').apply_to(cube_state)
    changed_parts = {
      [:F, 1, cube_size - 1] => :white,
      [:B, 1, cube_size - 1] => :yellow
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, x, cube_size - 1]] ||= :orange
      changed_parts[[:B, x, cube_size - 1]] ||= :white
      changed_parts[[:D, x, cube_size - 1]] ||= :red
      changed_parts[[:F, x, cube_size - 1]] ||= :yellow
      changed_parts[[:L, 1, x]] = :green
      changed_parts[[:L, x, cube_size - 2]] ||= :blue
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a L' move" do
    parse_algorithm("L'").apply_to(cube_state)
    changed_parts = {
      [:F, cube_size - 2, cube_size - 1] => :yellow,
      [:B, cube_size - 2, cube_size - 1] => :white
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, x, cube_size - 1]] ||= :red
      changed_parts[[:B, x, cube_size - 1]] ||= :yellow
      changed_parts[[:D, x, cube_size - 1]] ||= :orange
      changed_parts[[:F, x, cube_size - 1]] ||= :white
      changed_parts[[:L, cube_size - 2, x]] = :green
      changed_parts[[:L, x, cube_size - 2]] ||= :blue
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a D move' do
    parse_algorithm('D').apply_to(cube_state)
    changed_parts = {
      [:F, cube_size - 1, cube_size - 2] => :green,
      [:L, cube_size - 1, cube_size - 2] => :red,
      [:B, cube_size - 1, cube_size - 2] => :blue,
      [:R, cube_size - 1, cube_size - 2] => :orange
    }
    if cube_size > 3
      changed_parts[[:D, 1, cube_size - 2]] = :white
      changed_parts[[:D, cube_size - 2, 1]] = :yellow
    end
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, cube_size - 1, x]] ||= :blue
      changed_parts[[:L, cube_size - 1, x]] ||= :orange
      changed_parts[[:B, cube_size - 1, x]] ||= :green
      changed_parts[[:R, cube_size - 1, x]] ||= :red
      if cube_size > 3
        changed_parts[[:D, x, 1]] ||= :white
        changed_parts[[:D, x, cube_size - 2]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a D' move" do
    parse_algorithm("D'").apply_to(cube_state)
    changed_parts = {
      [:F, cube_size - 1, 1] => :blue,
      [:L, cube_size - 1, 1] => :orange,
      [:B, cube_size - 1, 1] => :green,
      [:R, cube_size - 1, 1] => :red
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, cube_size - 1, x]] ||= :green
      changed_parts[[:L, cube_size - 1, x]] ||= :red
      changed_parts[[:B, cube_size - 1, x]] ||= :blue
      changed_parts[[:R, cube_size - 1, x]] ||= :orange
      if cube_size > 3
        changed_parts[[:D, 1, x]] ||= :yellow
        changed_parts[[:D, cube_size - 2, x]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying an y rotation' do
    parse_algorithm('y').apply_to(cube_state)
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, x, 1]] = :blue
      changed_parts[[:L, x, 1]] = :orange
      changed_parts[[:B, x, 1]] = :green
      changed_parts[[:R, x, 1]] = :red
      0.upto(cube_size - 1) do |y|
        changed_parts[[:F, x, y]] ||= :green
        changed_parts[[:L, x, y]] ||= :red
        changed_parts[[:B, x, y]] ||= :blue
        changed_parts[[:R, x, y]] ||= :orange
      end
      next unless cube_size > 3

      changed_parts[[:U, 1, x]] ||= :white
      changed_parts[[:U, cube_size - 2, x]] ||= :yellow
      changed_parts[[:D, 1, x]] ||= :yellow
      changed_parts[[:D, cube_size - 2, x]] ||= :white
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying an y' rotation" do
    parse_algorithm("y'").apply_to(cube_state)
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:F, x, cube_size - 2]] = :green
      changed_parts[[:L, x, cube_size - 2]] = :red
      changed_parts[[:B, x, cube_size - 2]] = :blue
      changed_parts[[:R, x, cube_size - 2]] = :orange
      if cube_size > 3
        changed_parts[[:U, 1, cube_size - 2]] = :yellow
        changed_parts[[:U, cube_size - 2, 1]] = :white
        changed_parts[[:D, 1, cube_size - 2]] = :white
        changed_parts[[:D, cube_size - 2, 1]] = :yellow
      end
      0.upto(cube_size - 1) do |y|
        changed_parts[[:F, x, y]] ||= :blue
        changed_parts[[:L, x, y]] ||= :orange
        changed_parts[[:B, x, y]] ||= :green
        changed_parts[[:R, x, y]] ||= :red
      end
      next unless cube_size > 3

      changed_parts[[:U, x, 1]] ||= :yellow
      changed_parts[[:U, x, cube_size - 2]] ||= :white
      changed_parts[[:D, x, 1]] ||= :white
      changed_parts[[:D, x, cube_size - 2]] ||= :yellow
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a x rotaton' do
    parse_algorithm('x').apply_to(cube_state)
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:R, x, cube_size - 2]] = :green
      changed_parts[[:R, cube_size - 2, x]] = :blue
      changed_parts[[:L, x, cube_size - 2]] = :blue
      changed_parts[[:L, cube_size - 2, x]] = :green
      changed_parts[[:U, x, 1]] = :orange
      changed_parts[[:D, x, 1]] = :red
      changed_parts[[:B, cube_size - 2, x]] = :white
      changed_parts[[:B, x, 1]] = :white
      changed_parts[[:F, cube_size - 2, x]] = :yellow
      changed_parts[[:F, x, 1]] = :yellow
      0.upto(cube_size - 1) do |y|
        changed_parts[[:U, x, y]] ||= :red
        changed_parts[[:D, x, y]] ||= :orange
        changed_parts[[:F, x, y]] ||= :white
        changed_parts[[:B, x, y]] ||= :yellow
      end
    end
    changed_parts[[:F, cube_size - 2, cube_size - 2]] = :white
    changed_parts[[:B, cube_size - 2, cube_size - 2]] = :yellow
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should do fat U moves like D y' do
    fat_move = (cube_size - 1).to_s + 'Uw'
    parse_algorithm(fat_move).apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm('D y').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do fat R moves like L x' do
    fat_move = (cube_size - 1).to_s + 'Rw'
    parse_algorithm(fat_move).apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm('L x').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do fat F moves like B z' do
    fat_move = (cube_size - 1).to_s + 'Fw'
    parse_algorithm(fat_move).apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm('B z').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do a Niklas alg properly' do
    parse_algorithm("U' L' U R U' L U R'").apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    construct_cycle(Corner, %w[c i j]).apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do a TK wing alg properly if the cube is big enough' do
    if cube_size >= 4
      parse_algorithm("U' R' U r2 U' R U r2").apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      construct_cycle(Wing, %w[e t k]).apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it 'should do the T perm properly' do
    cube_state = color_scheme.solved_cube_state(cube_size)
    parse_algorithm("R U R' U' R' F R2 U' R' U' R U R' F'").apply_to(cube_state)
    expected_cube_state = color_scheme.solved_cube_state(cube_size)
    construct_cycle(Corner, %w[b d]).apply_to(expected_cube_state)
    if cube_size.odd? && cube_size >= 5
      construct_cycle(Midge, %w[b c]).apply_to(expected_cube_state)
    end
    construct_cycle(Edge, %w[b c]).apply_to(expected_cube_state) if cube_size == 3
    wing_incarnations = letter_scheme.for_letter(Wing, 'e').num_incarnations(cube_size)
    wing_incarnations.times do |incarnation_index|
      factory = PartCycleFactory.new(cube_size, incarnation_index)
      factory.construct([letter_scheme.for_letter(Wing, 'b'), letter_scheme.for_letter(Wing, 'c')]).apply_to(expected_cube_state)
      factory.construct([letter_scheme.for_letter(Wing, 'm'), letter_scheme.for_letter(Wing, 'i')]).apply_to(expected_cube_state)
    end
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do an E move properly if the cube size is odd' do
    if cube_size.odd?
      parse_algorithm('E').apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Dw' #{half_size}Uw y'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it 'should do an S move properly if the cube size is odd' do
    if cube_size.odd?
      parse_algorithm('S').apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Fw' #{half_size}Bw z")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it 'should do an M move properly if the cube size is odd' do
    if cube_size.odd?
      parse_algorithm('M').apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Lw' #{half_size}Rw x'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it "should do an E' move properly if the cube size is odd" do
    if cube_size.odd?
      parse_algorithm("E'").apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Dw #{half_size}Uw' y")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it "should do an S' move properly if the cube size is odd" do
    if cube_size.odd?
      parse_algorithm("S'").apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Fw #{half_size}Bw' z'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end

  it "should do an M' move properly if the cube size is odd" do
    if cube_size.odd?
      parse_algorithm("M'").apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Lw #{half_size}Rw' x")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
end

describe CubeState do
  context 'when the cube size is 3' do
    it_behaves_like 'cube_state', 3
  end

  context 'when the cube size is 4' do
    it_behaves_like 'cube_state', 4
  end

  context 'when the cube size is 5' do
    it_behaves_like 'cube_state', 5
  end

  context 'when the cube size is 6' do
    it_behaves_like 'cube_state', 6
  end

  context 'when the cube size is 7' do
    it_behaves_like 'cube_state', 7
  end
end
