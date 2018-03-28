require 'skewb_layer_finder'
require 'move'

include CubeTrainer

def parse_skewb_alg(alg_string)
  Algorithm.new(alg_string.split(' ').collect { |move_string| parse_skewb_move(move_string) })
end

describe SkewbLayerFinder do
  let (:cube_state) { SkewbState.solved }
  let (:layer_finder) { SkewbLayerFinder.new }

  it 'should find an existing layer' do
    expect(layer_finder.find_layer(cube_state, 0)).to be == [Algorithm.empty]
  end

  it 'should find a one move layer' do
    parse_skewb_move('U').apply_to(cube_state)
    expect(layer_finder.find_layer(cube_state, 1)).to be == [parse_skewb_alg('U\'')]
  end

  it 'should find a two move layer' do
    parse_skewb_alg('U R').apply_to(cube_state)
    expect(layer_finder.find_layer(cube_state, 2)).to be == [parse_skewb_alg('R\' U\'')]
  end

  it 'should not find a layer that takes too many moves' do
    parse_skewb_alg('U R').apply_to(cube_state)
    expect(layer_finder.find_layer(cube_state, 1)).to be == []
  end

  it 'should find multiple solutions if applicable' do
    parse_skewb_alg('B L\'').apply_to(cube_state)
    expect(layer_finder.find_layer(cube_state, 2)).to be == [parse_skewb_alg('B\' L'), parse_skewb_alg('L B\''), parse_skewb_alg('U\' L')]
  end
end
