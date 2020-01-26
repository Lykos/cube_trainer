require 'cube_trainer/cube_state'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/cube_constants'
require 'cube_trainer/cube'
require 'cube_trainer/move'
require 'cube_trainer/coordinate'
require 'cube_trainer/parser'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/color_scheme'

include CubeTrainer
include CubeConstants
include CubePrintHelper

RSpec.shared_examples 'cube_state' do |cube_size|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:color_scheme) { ColorScheme::BERNHARD }

  def for_letter(part_type, letter)
    letter_scheme.for_letter(part_type, letter)
  end

  def expect_stickers_changed(cube_state, changed_parts)
    original_state = create_interesting_cube_state(cube_state.n)
    FACE_SYMBOLS.each do |s|
      cube_state.n.times do |x|
        cube_state.n.times do |y|
          coordinate = Coordinate.new(Face.for_face_symbol(s), cube_state.n, x, y)
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
      state[Coordinate.new(Face::D, cube_size, a, 1)] = :yellow
      state[Coordinate.new(Face::D, cube_size, -2, a)] = :yellow
      state[Coordinate.new(Face::U, cube_size, a, 1)] = :white
      state[Coordinate.new(Face::U, cube_size, -2, a)] = :white
      state[Coordinate.new(Face::F, cube_size, a, 1)] = :orange
      state[Coordinate.new(Face::B, cube_size, a, 1)] = :red
      state[Coordinate.new(Face::L, cube_size, a, -2)] = :green
      state[Coordinate.new(Face::R, cube_size, a, -2)] = :blue
    end
    state[Coordinate.new(Face::D, cube_size, -2, -2)] = :white
    state[Coordinate.new(Face::U, cube_size, -2, -2)] = :yellow
    state
  end

  let (:cube_state) { create_interesting_cube_state(cube_size) }
  
  it 'should have the right state after applying a nice corner commutator' do
    cube_state.apply_piece_cycle([for_letter(Corner, 'c'), for_letter(Corner, 'd'), for_letter(Corner, 'k')])
    changed_parts = {
      [:U, cube_size - 1, cube_size - 1] => :green,
      [:R, 0, cube_size - 1] => :orange,
      [:R, cube_size - 1, cube_size - 1] => :yellow,
      [:B, 0, 0] => :blue,
      [:B, 0, cube_size - 1] => :white,
      [:L, 0, cube_size - 1] => :orange,
      [:D, cube_size - 1, 0] => :green,
    }
    expect_stickers_changed(cube_state, changed_parts)
  end
  
  it 'should have the right state after applying a nasty corner commutator' do
    cube_state.apply_piece_cycle([for_letter(Corner, 'c'), for_letter(Corner, 'h'), for_letter(Corner, 'g')])
    changed_parts = {
      [:U, cube_size - 1, cube_size - 1] => :red,
      [:U, 0, cube_size - 1] => :blue,
      [:L, 0, 0] => :white,
      [:L, cube_size - 1, 0] => :orange,
      [:D, 0, cube_size - 1] => :blue,
      [:B, 0, cube_size - 1] => :yellow,
      [:F, cube_size - 1, cube_size - 1] => :yellow,
    }
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a U move" do
    cube_state.apply_move(parse_move("U"))
    changed_parts = {
      [:F, 0, 1] => :blue,
      [:L, 0, 1] => :orange,
      [:B, 0, 1] => :green,
      [:R, 0, 1] => :red,
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
    cube_state.apply_move(parse_move("U'"))
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

  it "should have the right state after applying a R move" do
    cube_state.apply_move(parse_move("R"))
    changed_parts = {
      [:F, cube_size - 2, 0] => :yellow,
      [:B, cube_size - 2, 0] => :white,
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
    cube_state.apply_move(parse_move("R'"))
    changed_parts = {
      [:F, 1, 0] => :white,
      [:B, 1, 0] => :yellow,
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

  it "should have the right state after applying a F move" do
    cube_state.apply_move(parse_move("F"))
    changed_parts = {
      [:R, cube_size - 2, 0] => :white,
      [:L, cube_size - 2, 0] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, 0, x]] ||= :blue
      changed_parts[[:R, x, 0]] ||= :yellow
      changed_parts[[:D, 0, x]] ||= :green
      changed_parts[[:L, x, 0]] ||= :white
      changed_parts[[:F, cube_size - 2,  x]] = :orange
      changed_parts[[:F, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a F' move" do
    cube_state.apply_move(parse_move("F'"))
    changed_parts = {
      [:R, 1, 0] => :yellow,
      [:L, 1, 0] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, 0, x]] ||= :green
      changed_parts[[:R, x, 0]] ||= :white
      changed_parts[[:D, 0, x]] ||= :blue
      changed_parts[[:L, x, 0]] ||= :yellow
      changed_parts[[:F, 1,  x]] = :orange
      changed_parts[[:F, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a B move" do
    cube_state.apply_move(parse_move("B"))
    changed_parts = {
      [:R, 1, cube_size - 1] => :yellow,
      [:L, 1, cube_size - 1] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, cube_size - 1, x]] ||= :green
      changed_parts[[:R, x, cube_size - 1]] ||= :white
      changed_parts[[:D, cube_size - 1, x]] ||= :blue
      changed_parts[[:L, x, cube_size - 1]] ||= :yellow
      changed_parts[[:B, 1,  x]] = :red
      changed_parts[[:B, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying a B2 move" do
    cube_state.apply_move(parse_move("B2"))
    changed_parts = {
      [:U, cube_size - 1, cube_size - 2] => :yellow,
      [:D, cube_size - 1, cube_size - 2] => :white,
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
    cube_state.apply_move(parse_move("B'"))
    changed_parts = {
      [:R, cube_size - 2, cube_size - 1] => :white,
      [:L, cube_size - 2, cube_size - 1] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:U, cube_size - 1, x]] ||= :blue
      changed_parts[[:R, x, cube_size - 1]] ||= :yellow
      changed_parts[[:D, cube_size - 1, x]] ||= :green
      changed_parts[[:L, x, cube_size - 1]] ||= :white
      changed_parts[[:B, cube_size - 2,  x]] = :red
      changed_parts[[:B, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end
  
  it "should have the right state after applying a L move" do
    cube_state.apply_move(parse_move("L"))
    changed_parts = {
      [:F, 1, cube_size - 1] => :white,
      [:B, 1, cube_size - 1] => :yellow,
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
    cube_state.apply_move(parse_move("L'"))
    changed_parts = {
      [:F, cube_size - 2, cube_size - 1] => :yellow,
      [:B, cube_size - 2, cube_size - 1] => :white,
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

  it "should have the right state after applying a D move" do
    cube_state.apply_move(parse_move("D"))
    changed_parts = {
      [:F, cube_size - 1, cube_size - 2] => :green,
      [:L, cube_size - 1, cube_size - 2] => :red,
      [:B, cube_size - 1, cube_size - 2] => :blue,
      [:R, cube_size - 1, cube_size - 2] => :orange,
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
    cube_state.apply_move(parse_move("D'"))
    changed_parts = {
      [:F, cube_size - 1, 1] => :blue,
      [:L, cube_size - 1, 1] => :orange,
      [:B, cube_size - 1, 1] => :green,
      [:R, cube_size - 1, 1] => :red,
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

  it "should have the right state after applying an y rotation" do
    cube_state.apply_move(parse_move("y"))
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
      if cube_size > 3
        changed_parts[[:U, 1, x]] ||= :white
        changed_parts[[:U, cube_size - 2, x]] ||= :yellow
        changed_parts[[:D, 1, x]] ||= :yellow
        changed_parts[[:D, cube_size - 2, x]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it "should have the right state after applying an y' rotation" do
    cube_state.apply_move(parse_move("y'"))
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
      if cube_size > 3
        changed_parts[[:U, x, 1]] ||= :yellow
        changed_parts[[:U, x, cube_size - 2]] ||= :white
        changed_parts[[:D, x, 1]] ||= :white
        changed_parts[[:D, x, cube_size - 2]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end
 
  it "should have the right state after applying a x rotaton" do
    cube_state.apply_move(parse_move("x"))
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:R, x, cube_size - 2]] = :green
      changed_parts[[:R, cube_size - 2, x]] = :blue
      changed_parts[[:L, x, cube_size - 2]] = :blue
      changed_parts[[:L, cube_size - 2, x]] = :green
      changed_parts[[:U, x, 1]] = :orange
      changed_parts[[:D, x, 1]] = :red
      changed_parts[[:B, cube_size -2, x]] = :white
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

  it "should do fat U moves like D y" do
    fat_move = (cube_size - 1).to_s + "Uw"
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm("D y").apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it "should do fat R moves like L x" do
    fat_move = (cube_size - 1).to_s + "Rw"
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm("L x").apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it "should do fat F moves like B z" do
    fat_move = (cube_size - 1).to_s + "Fw"
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_algorithm("B z").apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it "should do a Niklas alg properly" do
    parse_algorithm("U' L' U R U' L U R'").apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    expected_cube_state.apply_piece_cycle([for_letter(Corner, "c"), for_letter(Corner, "i"), for_letter(Corner, "j")])
    expect(cube_state).to be == expected_cube_state
  end
  
  it "should do a TK wing alg properly if the cube is big enough" do
    if cube_size >= 4
      parse_algorithm("U' R' U r2 U' R U r2").apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      expected_cube_state.apply_piece_cycle([for_letter(Wing, "e"), for_letter(Wing, "t"), for_letter(Wing, "k")])
      expect(cube_state).to be == expected_cube_state
    end
  end

  it "should do the T perm properly" do
    cube_state = color_scheme.solved_cube_state(cube_size)
    parse_algorithm("R U R' U' R' F R2 U' R' U' R U R' F'").apply_to(cube_state)
    expected_cube_state = color_scheme.solved_cube_state(cube_size)
    expected_cube_state.apply_piece_cycle([for_letter(Corner, "b"), for_letter(Corner, "d")])
    if cube_size % 2 == 1 && cube_size >= 5
      expected_cube_state.apply_piece_cycle([for_letter(Midge, "b"), for_letter(Midge, "c")])
    end
    if cube_size == 3
      expected_cube_state.apply_piece_cycle([for_letter(Edge, "b"), for_letter(Edge, "c")])
    end
    wing_incarnations = for_letter(Wing, "e").num_incarnations(cube_size)
    wing_incarnations.times do |incarnation_index|
      expected_cube_state.apply_piece_cycle([for_letter(Wing, "b"), for_letter(Wing, "c")], incarnation_index)
      expected_cube_state.apply_piece_cycle([for_letter(Wing, "m"), for_letter(Wing, "i")], incarnation_index)
    end
    expect(cube_state).to be == expected_cube_state
  end
  
  it "should do an E move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("E"))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Dw' #{half_size}Uw y'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it "should do an S move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("S"))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Fw' #{half_size}Bw z")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it "should do an M move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("M"))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Lw' #{half_size}Rw x'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it "should do an E' move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("E'"))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Dw #{half_size}Uw' y")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it "should do an S' move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("S'"))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_algorithm("#{half_size}Fw #{half_size}Bw' z'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it "should do an M' move properly if the cube size is odd" do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move("M'"))
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
