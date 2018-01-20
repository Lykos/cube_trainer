require 'cube_state'
require 'cube'
require 'rspec/expectations'

include CubeTrainer

describe CubeState do
  let (:cube_state5) { CubeState.solved(5) }
  let (:white_face) { Face.new([:white]) }
  let (:yellow_face) { Face.new([:yellow]) }
  let (:red_face) { Face.new([:red]) }
  let (:orange_face) { Face.new([:orange]) }
  let (:green_face) { Face.new([:green]) }
  let (:blue_face) { Face.new([:blue]) }

  def expect_stickers_changed(cube_state, changed_parts)
    COLORS.each do |c|
      5.times do |x|
        5.times do |y|
          expected_color = changed_parts[[c, x, y]] || c
          expect(cube_state5[Face.for_color(c), x, y]).to be == expected_color
        end
      end
    end
  end

  def parse_alg(alg_string)
    alg_string.split(' ').collect { |move_string| parse_move(move_string) }
  end

  it 'should have the right state after applying a corner commutator' do
    cube_state5.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('h'), Corner.for_letter('g')])
    changed_parts = {
      [:yellow, 4, 4] => :red,
      [:yellow, 0, 4] => :blue,
      [:blue, 0, 0] => :white,
      [:blue, 4, 0] => :orange,
      [:white, 0, 4] => :blue,
      [:orange, 0, 4] => :yellow,
      [:red, 4, 4] => :yellow,
    }
    puts cube_state5.to_s.split('\n')
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a U move' do
    cube_state5.apply_move(parse_move('U'))
    changed_parts = {
      [:red, 0, 0] => :green,
      [:red, 0, 1] => :green,
      [:red, 0, 2] => :green,
      [:red, 0, 3] => :green,
      [:red, 0, 4] => :green,
      [:blue, 0, 0] => :red,
      [:blue, 0, 1] => :red,
      [:blue, 0, 2] => :red,
      [:blue, 0, 3] => :red,
      [:blue, 0, 4] => :red,
      [:orange, 0, 0] => :blue,
      [:orange, 0, 1] => :blue,
      [:orange, 0, 2] => :blue,
      [:orange, 0, 3] => :blue,
      [:orange, 0, 4] => :blue,
      [:green, 0, 0] => :orange,
      [:green, 0, 1] => :orange,
      [:green, 0, 2] => :orange,
      [:green, 0, 3] => :orange,
      [:green, 0, 4] => :orange,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a U\' move' do
    cube_state5.apply_move(parse_move('U\''))
    changed_parts = {
      [:red, 0, 0] => :blue,
      [:red, 0, 1] => :blue,
      [:red, 0, 2] => :blue,
      [:red, 0, 3] => :blue,
      [:red, 0, 4] => :blue,
      [:blue, 0, 0] => :orange,
      [:blue, 0, 1] => :orange,
      [:blue, 0, 2] => :orange,
      [:blue, 0, 3] => :orange,
      [:blue, 0, 4] => :orange,
      [:orange, 0, 0] => :green,
      [:orange, 0, 1] => :green,
      [:orange, 0, 2] => :green,
      [:orange, 0, 3] => :green,
      [:orange, 0, 4] => :green,
      [:green, 0, 0] => :red,
      [:green, 0, 1] => :red,
      [:green, 0, 2] => :red,
      [:green, 0, 3] => :red,
      [:green, 0, 4] => :red,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a R move' do
    cube_state5.apply_move(parse_move('R'))
    changed_parts = {
      [:red, 0, 0] => :white,
      [:red, 1, 0] => :white,
      [:red, 2, 0] => :white,
      [:red, 3, 0] => :white,
      [:red, 4, 0] => :white,
      [:yellow, 0, 0] => :red,
      [:yellow, 1, 0] => :red,
      [:yellow, 2, 0] => :red,
      [:yellow, 3, 0] => :red,
      [:yellow, 4, 0] => :red,
      [:orange, 0, 0] => :yellow,
      [:orange, 1, 0] => :yellow,
      [:orange, 2, 0] => :yellow,
      [:orange, 3, 0] => :yellow,
      [:orange, 4, 0] => :yellow,
      [:white, 0, 0] => :orange,
      [:white, 1, 0] => :orange,
      [:white, 2, 0] => :orange,
      [:white, 3, 0] => :orange,
      [:white, 4, 0] => :orange,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a R\' move' do
    cube_state5.apply_move(parse_move('R\''))
    changed_parts = {
      [:red, 0, 0] => :yellow,
      [:red, 1, 0] => :yellow,
      [:red, 2, 0] => :yellow,
      [:red, 3, 0] => :yellow,
      [:red, 4, 0] => :yellow,
      [:yellow, 0, 0] => :orange,
      [:yellow, 1, 0] => :orange,
      [:yellow, 2, 0] => :orange,
      [:yellow, 3, 0] => :orange,
      [:yellow, 4, 0] => :orange,
      [:orange, 0, 0] => :white,
      [:orange, 1, 0] => :white,
      [:orange, 2, 0] => :white,
      [:orange, 3, 0] => :white,
      [:orange, 4, 0] => :white,
      [:white, 0, 0] => :red,
      [:white, 1, 0] => :red,
      [:white, 2, 0] => :red,
      [:white, 3, 0] => :red,
      [:white, 4, 0] => :red,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a F move' do
    cube_state5.apply_move(parse_move('F'))
    changed_parts = {
      [:yellow, 0, 0] => :blue,
      [:yellow, 0, 1] => :blue,
      [:yellow, 0, 2] => :blue,
      [:yellow, 0, 3] => :blue,
      [:yellow, 0, 4] => :blue,
      [:green, 0, 0] => :yellow,
      [:green, 1, 0] => :yellow,
      [:green, 2, 0] => :yellow,
      [:green, 3, 0] => :yellow,
      [:green, 4, 0] => :yellow,
      [:white, 0, 0] => :green,
      [:white, 0, 1] => :green,
      [:white, 0, 2] => :green,
      [:white, 0, 3] => :green,
      [:white, 0, 4] => :green,
      [:blue, 0, 0] => :white,
      [:blue, 1, 0] => :white,
      [:blue, 2, 0] => :white,
      [:blue, 3, 0] => :white,
      [:blue, 4, 0] => :white,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end
  
  it 'should have the right state after applying a B move' do
    cube_state5.apply_move(parse_move('B'))
    changed_parts = {
      [:yellow, 4, 0] => :green,
      [:yellow, 4, 1] => :green,
      [:yellow, 4, 2] => :green,
      [:yellow, 4, 3] => :green,
      [:yellow, 4, 4] => :green,
      [:green, 0, 4] => :white,
      [:green, 1, 4] => :white,
      [:green, 2, 4] => :white,
      [:green, 3, 4] => :white,
      [:green, 4, 4] => :white,
      [:white, 4, 0] => :blue,
      [:white, 4, 1] => :blue,
      [:white, 4, 2] => :blue,
      [:white, 4, 3] => :blue,
      [:white, 4, 4] => :blue,
      [:blue, 0, 4] => :yellow,
      [:blue, 1, 4] => :yellow,
      [:blue, 2, 4] => :yellow,
      [:blue, 3, 4] => :yellow,
      [:blue, 4, 4] => :yellow,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a L move' do
    cube_state5.apply_move(parse_move('L'))
    changed_parts = {
      [:red, 0, 4] => :yellow,
      [:red, 1, 4] => :yellow,
      [:red, 2, 4] => :yellow,
      [:red, 3, 4] => :yellow,
      [:red, 4, 4] => :yellow,
      [:yellow, 0, 4] => :orange,
      [:yellow, 1, 4] => :orange,
      [:yellow, 2, 4] => :orange,
      [:yellow, 3, 4] => :orange,
      [:yellow, 4, 4] => :orange,
      [:orange, 0, 4] => :white,
      [:orange, 1, 4] => :white,
      [:orange, 2, 4] => :white,
      [:orange, 3, 4] => :white,
      [:orange, 4, 4] => :white,
      [:white, 0, 4] => :red,
      [:white, 1, 4] => :red,
      [:white, 2, 4] => :red,
      [:white, 3, 4] => :red,
      [:white, 4, 4] => :red,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should have the right state after applying a L'' move' do
    cube_state5.apply_move(parse_move('L\''))
    changed_parts = {
      [:red, 0, 4] => :white,
      [:red, 1, 4] => :white,
      [:red, 2, 4] => :white,
      [:red, 3, 4] => :white,
      [:red, 4, 4] => :white,
      [:yellow, 0, 4] => :red,
      [:yellow, 1, 4] => :red,
      [:yellow, 2, 4] => :red,
      [:yellow, 3, 4] => :red,
      [:yellow, 4, 4] => :red,
      [:orange, 0, 4] => :yellow,
      [:orange, 1, 4] => :yellow,
      [:orange, 2, 4] => :yellow,
      [:orange, 3, 4] => :yellow,
      [:orange, 4, 4] => :yellow,
      [:white, 0, 4] => :orange,
      [:white, 1, 4] => :orange,
      [:white, 2, 4] => :orange,
      [:white, 3, 4] => :orange,
      [:white, 4, 4] => :orange,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end
  
  it 'should have the right state after applying a D move' do
    cube_state5.apply_move(parse_move('D'))
    changed_parts = {
      [:red, 4, 0] => :blue,
      [:red, 4, 1] => :blue,
      [:red, 4, 2] => :blue,
      [:red, 4, 3] => :blue,
      [:red, 4, 4] => :blue,
      [:blue, 4, 0] => :orange,
      [:blue, 4, 1] => :orange,
      [:blue, 4, 2] => :orange,
      [:blue, 4, 3] => :orange,
      [:blue, 4, 4] => :orange,
      [:orange, 4, 0] => :green,
      [:orange, 4, 1] => :green,
      [:orange, 4, 2] => :green,
      [:orange, 4, 3] => :green,
      [:orange, 4, 4] => :green,
      [:green, 4, 0] => :red,
      [:green, 4, 1] => :red,
      [:green, 4, 2] => :red,
      [:green, 4, 3] => :red,
      [:green, 4, 4] => :red,
    }
    expect_stickers_changed(cube_state5, changed_parts)
  end

  it 'should do a Niklas properly' do
    parse_alg('U\' L\' U R U\' L U R\'').each do |move|
      cube_state5.apply_move(move)
    end
    expected_cube_state = CubeState.solved(5)
    expected_cube_state.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('i'), Corner.for_letter('j')])
    expect(cube_state5).to be == expected_cube_state
  end

  it 'should do the T perm properly' do
    parse_alg('R U R\' U\' R\' F R2 U\' R\' U\' R U R\' F\'').each do |move|
      cube_state5.apply_move(move)
      #puts move
      #puts cube_state5.to_s.split('\n')
    end
    expected_cube_state = CubeState.solved(5)
    expected_cube_state.apply_piece_cycle([Corner.for_letter('b'), Corner.for_letter('d')])
    expected_cube_state.apply_piece_cycle([Midge.for_letter('b'), Midge.for_letter('c')])
    expected_cube_state.apply_piece_cycle([Wing.for_letter('b'), Wing.for_letter('c')])
    expected_cube_state.apply_piece_cycle([Wing.for_letter('m'), Wing.for_letter('i')])
    #puts expected_cube_state.to_s.split('\n')
    #p Wing.for_letter('i')
    #p Wing.for_letter('i').corresponding_part
    #p expected_cube_state.solved_positions(Wing.for_letter('i'))
    expect(cube_state5).to be == expected_cube_state
  end

  it 'should return the right face priority' do
    expect(cube_state5.face_priority(yellow_face)).to be == 0
    expect(cube_state5.face_priority(white_face)).to be == 0
    expect(cube_state5.face_priority(red_face)).to be == 1
    expect(cube_state5.face_priority(orange_face)).to be == 1
    expect(cube_state5.face_priority(green_face)).to be == 2
    expect(cube_state5.face_priority(blue_face)).to be == 2
  end

  it 'should answer which faces are close to smaller indices' do
    expect(cube_state5.close_to_smaller_indices?(yellow_face)).to be true
    expect(cube_state5.close_to_smaller_indices?(white_face)).to be false
    expect(cube_state5.close_to_smaller_indices?(red_face)).to be true
    expect(cube_state5.close_to_smaller_indices?(orange_face)).to be false
    expect(cube_state5.close_to_smaller_indices?(green_face)).to be true
    expect(cube_state5.close_to_smaller_indices?(blue_face)).to be false
  end
end
