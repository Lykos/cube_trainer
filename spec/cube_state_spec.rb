require 'cube_state'

describe CubeState do
  let (:cube_state) { CubeState.solved(5) }
  it 'should have the right state after applying a corner commutator' do
    cube_state.apply_piece_cycle([Corner.for_letter('c'), Corner.for_letter('h'), Corner.for_letter('g')])
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
      expect(cube_state[COLORS.index(c), x, y]).to be == c
    end
    COLORS.each_with_index do |c, i|
      5.times do |x|
        5.times do |y|
          next if changed_indices.has_key?([c, x, y])
          expect(cube_state[i, x, y]).to be == c
        end
      end
    end
  end
end
