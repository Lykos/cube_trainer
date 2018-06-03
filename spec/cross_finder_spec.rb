require 'cross_finder'
require 'move'

include CubeTrainer

def parse_alg(alg_string)
  Algorithm.new(alg_string.split(' ').collect { |move_string| parse_move(move_string) })
end

describe CrossFinder do
  let (:cube_state) { CubeState.solved(3) }
  let (:cross_finder) { CrossFinder.new }

  it 'should find an existing cross' do
    expect(cross_finder.find_cross(cube_state, 0).extract_algorithms).to be == {
      :yellow => [Algorithm.empty],
      :red => [Algorithm.empty],
      :green => [Algorithm.empty],
      :blue => [Algorithm.empty],
      :orange => [Algorithm.empty],
      :white => [Algorithm.empty]}
  end

  it 'should not find a cross that takes too many moves' do
    parse_alg('U R F').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be == {}
  end

  it 'should find a one move cross' do
    parse_alg('U R').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be == {
      :blue => [parse_alg('U\'')],
      :white => [parse_alg('R\'')]}
  end
end
