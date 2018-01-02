require 'cube_state'
require 'cube'
require 'rspec/expectations'

describe CubeState do
  let (:cube_state5) { CubeState.solved(5) }
  let (:white_face) { Face.new([:white]) }
  let (:yellow_face) { Face.new([:yellow]) }
  let (:red_face) { Face.new([:red]) }
  let (:orange_face) { Face.new([:orange]) }
  let (:green_face) { Face.new([:green]) }
  let (:blue_face) { Face.new([:blue]) }
  
  it 'should have the right state after applying a corner commutator' do
    cube_state5.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('h'), Corner.for_letter('g')])
    changed_indices = {
      [:yellow, 4, 4] => :red,
      [:yellow, 0, 4] => :blue,
      [:blue, 0, 0] => :white,
      [:blue, 4, 0] => :orange,
      [:white, 0, 4] => :blue,
      [:orange, 0, 4] => :yellow,
      [:red, 4, 4] => :yellow,
    }
    changed_indices.each do |index, c|
      c, x, y = index
      expect(cube_state5[COLORS.index(c), x, y]).to be == c
    end
    COLORS.each_with_index do |c, i|
      5.times do |x|
        5.times do |y|
          next if changed_indices.has_key?([c, x, y])
          expect(cube_state5[i, x, y]).to be == c
        end
      end
    end
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
