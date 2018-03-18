require 'cube_state'
require 'cube'
require 'coordinate'

include CubeTrainer

def parse_alg(alg_string)
  Algorithm.new(alg_string.split(' ').collect { |move_string| parse_move(move_string) })
end

RSpec.shared_examples "cube_state" do |cube_size|
  def expect_stickers_changed(cube_state, changed_parts)
    original_state = create_interesting_cube_state(cube_state.n)
    COLORS.each do |c|
      cube_state.n.times do |x|
        cube_state.n.times do |y|
          coordinate = Coordinate.new(Face.for_color(c), cube_state.n, x, y)
          expected_color = changed_parts[[c, x, y]] || original_state[coordinate]
          p coordinate, cube_state[coordinate], expected_color, changed_parts[[c, x, y]] if cube_state[coordinate] != expected_color
          expect(cube_state[coordinate]).to be == expected_color
        end
      end
    end
  end

  def create_interesting_cube_state(cube_size)
    state = CubeState.solved(cube_size)
    # The state is like a r2 b2 to make turns a bit more interesting than solved faces.
    0.upto(cube_size - 1) do |a|
      state[Coordinate.new(white_face, cube_size, a, 1)] = :yellow
      state[Coordinate.new(white_face, cube_size, -2, a)] = :yellow
      state[Coordinate.new(yellow_face, cube_size, a, 1)] = :white
      state[Coordinate.new(yellow_face, cube_size, -2, a)] = :white
      state[Coordinate.new(red_face, cube_size, a, 1)] = :orange
      state[Coordinate.new(orange_face, cube_size, a, 1)] = :red
      state[Coordinate.new(blue_face, cube_size, a, -2)] = :green
      state[Coordinate.new(green_face, cube_size, a, -2)] = :blue
    end
    state[Coordinate.new(white_face, cube_size, -2, -2)] = :white
    state[Coordinate.new(yellow_face, cube_size, -2, -2)] = :yellow
    state
  end

  let (:white_face) { Face.for_color(:white) }
  let (:yellow_face) { Face.for_color(:yellow) }
  let (:red_face) { Face.for_color(:red) }
  let (:orange_face) { Face.for_color(:orange) }
  let (:green_face) { Face.for_color(:green) }
  let (:blue_face) { Face.for_color(:blue) }
  let (:cube_state) { create_interesting_cube_state(cube_size) }
  
  it 'should have the right state after applying a nice corner commutator' do
    cube_state.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('d'), Corner.for_letter('k')])
    changed_parts = {
      [:yellow, cube_size - 1, cube_size - 1] => :green,
      [:green, 0, cube_size - 1] => :orange,
      [:green, cube_size - 1, cube_size - 1] => :yellow,
      [:orange, 0, 0] => :blue,
      [:orange, 0, cube_size - 1] => :white,
      [:blue, 0, cube_size - 1] => :orange,
      [:white, cube_size - 1, 0] => :green,
    }
    expect_stickers_changed(cube_state, changed_parts)
  end
  
  it 'should have the right state after applying a nasty corner commutator' do
    cube_state.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('h'), Corner.for_letter('g')])
    changed_parts = {
      [:yellow, cube_size - 1, cube_size - 1] => :red,
      [:yellow, 0, cube_size - 1] => :blue,
      [:blue, 0, 0] => :white,
      [:blue, cube_size - 1, 0] => :orange,
      [:white, 0, cube_size - 1] => :blue,
      [:orange, 0, cube_size - 1] => :yellow,
      [:red, cube_size - 1, cube_size - 1] => :yellow,
    }
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a U move' do
    cube_state.apply_move(parse_move('U'))
    changed_parts = {
      [:red, 0, 1] => :blue,
      [:blue, 0, 1] => :orange,
      [:orange, 0, 1] => :green,
      [:green, 0, 1] => :red,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, 0, x]] ||= :green
      changed_parts[[:blue, 0, x]] ||= :red
      changed_parts[[:orange, 0, x]] ||= :blue
      changed_parts[[:green, 0, x]] ||= :orange
      if cube_size > 3
        changed_parts[[:yellow, 1, x]] ||= :white
        changed_parts[[:yellow, cube_size - 2, x]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a U\' move' do
    cube_state.apply_move(parse_move('U\''))
    changed_parts = {
      [:red, 0, cube_size - 2] => :green,
      [:blue, 0, cube_size - 2] => :red,
      [:orange, 0, cube_size - 2] => :blue,
      [:green, 0, cube_size - 2] => :orange
    }
    if cube_size > 3 
      changed_parts[[:yellow, 1, cube_size - 2]] = :yellow
      changed_parts[[:yellow, cube_size - 2, 1]] = :white
    end
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, 0, x]] ||= :blue
      changed_parts[[:blue, 0, x]] ||= :orange
      changed_parts[[:orange, 0, x]] ||= :green
      changed_parts[[:green, 0, x]] ||= :red
      if cube_size > 3
        changed_parts[[:yellow, x, 1]] ||= :yellow
        changed_parts[[:yellow, x, cube_size - 2]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a R move' do
    cube_state.apply_move(parse_move('R'))
    changed_parts = {
      [:red, cube_size - 2, 0] => :yellow,
      [:orange, cube_size - 2, 0] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, x, 0]] ||= :red
      changed_parts[[:orange, x, 0]] ||= :yellow
      changed_parts[[:white, x, 0]] ||= :orange
      changed_parts[[:red, x, 0]] ||= :white
      changed_parts[[:green, cube_size - 2, x]] = :blue
      changed_parts[[:green, x, cube_size - 2]] ||= :green
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a R\' move' do
    cube_state.apply_move(parse_move('R\''))
    changed_parts = {
      [:red, 1, 0] => :white,
      [:orange, 1, 0] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, x, 0]] ||= :orange
      changed_parts[[:orange, x, 0]] ||= :white
      changed_parts[[:white, x, 0]] ||= :red
      changed_parts[[:red, x, 0]] ||= :yellow
      changed_parts[[:green, 1, x]] = :blue
      changed_parts[[:green, x, cube_size - 2]] ||= :green
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a F move' do
    cube_state.apply_move(parse_move('F'))
    changed_parts = {
      [:green, cube_size - 2, 0] => :white,
      [:blue, cube_size - 2, 0] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, 0, x]] ||= :blue
      changed_parts[[:green, x, 0]] ||= :yellow
      changed_parts[[:white, 0, x]] ||= :green
      changed_parts[[:blue, x, 0]] ||= :white
      changed_parts[[:red, cube_size - 2,  x]] = :orange
      changed_parts[[:red, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a F\' move' do
    cube_state.apply_move(parse_move('F\''))
    changed_parts = {
      [:green, 1, 0] => :yellow,
      [:blue, 1, 0] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, 0, x]] ||= :green
      changed_parts[[:green, x, 0]] ||= :white
      changed_parts[[:white, 0, x]] ||= :blue
      changed_parts[[:blue, x, 0]] ||= :yellow
      changed_parts[[:red, 1,  x]] = :orange
      changed_parts[[:red, x, 1]] ||= :red
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a B move' do
    cube_state.apply_move(parse_move('B'))
    changed_parts = {
      [:green, 1, cube_size - 1] => :yellow,
      [:blue, 1, cube_size - 1] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, cube_size - 1, x]] ||= :green
      changed_parts[[:green, x, cube_size - 1]] ||= :white
      changed_parts[[:white, cube_size - 1, x]] ||= :blue
      changed_parts[[:blue, x, cube_size - 1]] ||= :yellow
      changed_parts[[:orange, 1,  x]] = :red
      changed_parts[[:orange, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a B\' move' do
    cube_state.apply_move(parse_move('B\''))
    changed_parts = {
      [:green, cube_size - 2, cube_size - 1] => :white,
      [:blue, cube_size - 2, cube_size - 1] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, cube_size - 1, x]] ||= :blue
      changed_parts[[:green, x, cube_size - 1]] ||= :yellow
      changed_parts[[:white, cube_size - 1, x]] ||= :green
      changed_parts[[:blue, x, cube_size - 1]] ||= :white
      changed_parts[[:orange, cube_size - 2,  x]] = :red
      changed_parts[[:orange, x, 1]] ||= :orange
    end
    expect_stickers_changed(cube_state, changed_parts)
  end
  
  it 'should have the right state after applying a L move' do
    cube_state.apply_move(parse_move('L'))
    changed_parts = {
      [:red, 1, cube_size - 1] => :white,
      [:orange, 1, cube_size - 1] => :yellow,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, x, cube_size - 1]] ||= :orange
      changed_parts[[:orange, x, cube_size - 1]] ||= :white
      changed_parts[[:white, x, cube_size - 1]] ||= :red
      changed_parts[[:red, x, cube_size - 1]] ||= :yellow
      changed_parts[[:blue, 1, x]] = :green
      changed_parts[[:blue, x, cube_size - 2]] ||= :blue
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a L\' move' do
    cube_state.apply_move(parse_move('L\''))
    changed_parts = {
      [:red, cube_size - 2, cube_size - 1] => :yellow,
      [:orange, cube_size - 2, cube_size - 1] => :white,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:yellow, x, cube_size - 1]] ||= :red
      changed_parts[[:orange, x, cube_size - 1]] ||= :yellow
      changed_parts[[:white, x, cube_size - 1]] ||= :orange
      changed_parts[[:red, x, cube_size - 1]] ||= :white
      changed_parts[[:blue, cube_size - 2, x]] = :green
      changed_parts[[:blue, x, cube_size - 2]] ||= :blue
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a D move' do
    cube_state.apply_move(parse_move('D'))
    changed_parts = {
      [:red, cube_size - 1, cube_size - 2] => :green,
      [:blue, cube_size - 1, cube_size - 2] => :red,
      [:orange, cube_size - 1, cube_size - 2] => :blue,
      [:green, cube_size - 1, cube_size - 2] => :orange,
    }
    if cube_size > 3 
      changed_parts[[:white, 1, cube_size - 2]] = :white
      changed_parts[[:white, cube_size - 2, 1]] = :yellow
    end
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, cube_size - 1, x]] ||= :blue
      changed_parts[[:blue, cube_size - 1, x]] ||= :orange
      changed_parts[[:orange, cube_size - 1, x]] ||= :green
      changed_parts[[:green, cube_size - 1, x]] ||= :red
      if cube_size > 3
        changed_parts[[:white, x, 1]] ||= :white
        changed_parts[[:white, x, cube_size - 2]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying a D\' move' do
    cube_state.apply_move(parse_move('D\''))
    changed_parts = {
      [:red, cube_size - 1, 1] => :blue,
      [:blue, cube_size - 1, 1] => :orange,
      [:orange, cube_size - 1, 1] => :green,
      [:green, cube_size - 1, 1] => :red,
    }
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, cube_size - 1, x]] ||= :green
      changed_parts[[:blue, cube_size - 1, x]] ||= :red
      changed_parts[[:orange, cube_size - 1, x]] ||= :blue
      changed_parts[[:green, cube_size - 1, x]] ||= :orange
      if cube_size > 3
        changed_parts[[:white, 1, x]] ||= :yellow
        changed_parts[[:white, cube_size - 2, x]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying an y rotation' do
    cube_state.apply_move(parse_move('y'))
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, x, 1]] = :blue
      changed_parts[[:blue, x, 1]] = :orange
      changed_parts[[:orange, x, 1]] = :green
      changed_parts[[:green, x, 1]] = :red
      0.upto(cube_size - 1) do |y|
        changed_parts[[:red, x, y]] ||= :green
        changed_parts[[:blue, x, y]] ||= :red
        changed_parts[[:orange, x, y]] ||= :blue
        changed_parts[[:green, x, y]] ||= :orange
      end
      if cube_size > 3
        changed_parts[[:yellow, 1, x]] ||= :white
        changed_parts[[:yellow, cube_size - 2, x]] ||= :yellow
        changed_parts[[:white, 1, x]] ||= :yellow
        changed_parts[[:white, cube_size - 2, x]] ||= :white
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should have the right state after applying an y\' rotation' do
    cube_state.apply_move(parse_move('y\''))
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:red, x, cube_size - 2]] = :green
      changed_parts[[:blue, x, cube_size - 2]] = :red
      changed_parts[[:orange, x, cube_size - 2]] = :blue
      changed_parts[[:green, x, cube_size - 2]] = :orange
      if cube_size > 3 
        changed_parts[[:yellow, 1, cube_size - 2]] = :yellow
        changed_parts[[:yellow, cube_size - 2, 1]] = :white
        changed_parts[[:white, 1, cube_size - 2]] = :white
        changed_parts[[:white, cube_size - 2, 1]] = :yellow
      end
      0.upto(cube_size - 1) do |y|
        changed_parts[[:red, x, y]] ||= :blue
        changed_parts[[:blue, x, y]] ||= :orange
        changed_parts[[:orange, x, y]] ||= :green
        changed_parts[[:green, x, y]] ||= :red
      end
      if cube_size > 3
        changed_parts[[:yellow, x, 1]] ||= :yellow
        changed_parts[[:yellow, x, cube_size - 2]] ||= :white
        changed_parts[[:white, x, 1]] ||= :white
        changed_parts[[:white, x, cube_size - 2]] ||= :yellow
      end
    end
    expect_stickers_changed(cube_state, changed_parts)
  end
 
  it 'should have the right state after applying a x rotaton' do
    cube_state.apply_move(parse_move('x'))
    changed_parts = {}
    0.upto(cube_size - 1) do |x|
      changed_parts[[:green, x, cube_size - 2]] = :green
      changed_parts[[:green, cube_size - 2, x]] = :blue
      changed_parts[[:blue, x, cube_size - 2]] = :blue
      changed_parts[[:blue, cube_size - 2, x]] = :green
      changed_parts[[:yellow, x, 1]] = :orange
      changed_parts[[:white, x, 1]] = :red
      changed_parts[[:orange, cube_size -2, x]] = :white
      changed_parts[[:orange, x, 1]] = :white
      changed_parts[[:red, cube_size - 2, x]] = :yellow
      changed_parts[[:red, x, 1]] = :yellow
      0.upto(cube_size - 1) do |y|
        changed_parts[[:yellow, x, y]] ||= :red
        changed_parts[[:white, x, y]] ||= :orange
        changed_parts[[:red, x, y]] ||= :white
        changed_parts[[:orange, x, y]] ||= :yellow
      end
    end
    changed_parts[[:red, cube_size - 2, cube_size - 2]] = :white
    changed_parts[[:orange, cube_size - 2, cube_size - 2]] = :yellow
    expect_stickers_changed(cube_state, changed_parts)
  end

  it 'should do fat U moves like D y' do
    fat_move = (cube_size - 1).to_s + 'Uw'
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_alg('D y').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do fat R moves like L x' do
    fat_move = (cube_size - 1).to_s + 'Rw'
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_alg('L x').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do fat F moves like B z' do
    fat_move = (cube_size - 1).to_s + 'Fw'
    cube_state.apply_move(parse_move(fat_move))
    expected_cube_state = create_interesting_cube_state(cube_size)
    parse_alg('B z').apply_to(expected_cube_state)
    expect(cube_state).to be == expected_cube_state
  end

  it 'should do a Niklas alg properly' do
    parse_alg('U\' L\' U R U\' L U R\'').apply_to(cube_state)
    expected_cube_state = create_interesting_cube_state(cube_size)
    expected_cube_state.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('i'), Corner.for_letter('j')])
    expect(cube_state).to be == expected_cube_state
  end
  
  it 'should do a TK wing alg properly if the cube is big enough' do
    if cube_size >= 4
      parse_alg('U\' R\' U r2 U\' R U r2').apply_to(cube_state)
      expected_cube_state = create_interesting_cube_state(cube_size)
      expected_cube_state.apply_piece_cycle([Wing.for_letter('e'), Wing.for_letter('t'), Wing.for_letter('k')])
      expect(cube_state).to be == expected_cube_state
    end
  end

  it 'should do the T perm properly' do
    cube_state = CubeState.solved(cube_size)
    parse_alg('R U R\' U\' R\' F R2 U\' R\' U\' R U R\' F\'').apply_to(cube_state)
    expected_cube_state = CubeState.solved(cube_size)
    expected_cube_state.apply_piece_cycle([Corner.for_letter('b'), Corner.for_letter('d')])
    if cube_size % 2 == 1 && cube_size >= 5
      expected_cube_state.apply_piece_cycle([Midge.for_letter('b'), Midge.for_letter('c')])
    end
    if cube_size == 3
      expected_cube_state.apply_piece_cycle([Edge.for_letter('b'), Edge.for_letter('c')])
    end
    wing_incarnations = Wing::BUFFER.num_incarnations(cube_size)
    wing_incarnations.times do |incarnation_index|
      expected_cube_state.apply_piece_cycle([Wing.for_letter('b'), Wing.for_letter('c')], incarnation_index)
      expected_cube_state.apply_piece_cycle([Wing.for_letter('m'), Wing.for_letter('i')], incarnation_index)
    end
    expect(cube_state).to be == expected_cube_state
  end
  
  it 'should do an E move properly if the cube size is odd' do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move('E'))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_alg("#{half_size}Dw' #{half_size}Uw y'")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it 'should do an E move properly if the cube size is odd' do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move('S'))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_alg("#{half_size}Fw' #{half_size}Bw z")
      equivalent_alg.apply_to(expected_cube_state)
      expect(cube_state).to be == expected_cube_state
    end
  end
  
  it 'should do an E move properly if the cube size is odd' do
    if cube_size % 2 == 1
      cube_state.apply_move(parse_move('M'))
      expected_cube_state = create_interesting_cube_state(cube_size)
      half_size = cube_size / 2
      equivalent_alg = parse_alg("#{half_size}Lw' #{half_size}Rw x'")
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
