require 'skewb_layer_finder'
require 'move'
require 'algorithm'
require 'cube_print_helper'
require 'parser'

include CubeTrainer
include CubePrintHelper

def parse_skewb_alg(alg_string)
  Algorithm.new(alg_string.split(' ').collect { |move_string| parse_skewb_move(move_string) })
end

describe SkewbLayerFinder do
  let (:skewb_state) { SkewbState.solved }
  
  context 'when restricted' do
    let (:layer_finder) { SkewbLayerFinder.new([:white]) }
    
    it 'should find an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to be == {
        :white => [Algorithm.empty]}
    end
    
    it 'should find the perfect score without moves' do
      expect(layer_finder.state_score(skewb_state)).to be == 4
    end

    it 'should find the score after one move' do
      parse_skewb_move("R").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 3
    end

    it 'should find the score after two moves that destroy adjacent things' do
      parse_skewb_algorithm("R U").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 2
    end

    it 'should find the score after two moves that destroy opposite things' do
      parse_skewb_algorithm("R L").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 2
    end

    it 'should find the score after three moves' do
      parse_skewb_algorithm("R U B").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 2
    end

    it 'should find the score after three destructive moves' do
      parse_skewb_algorithm("R U L").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 1
    end

    it 'should find the score after three destructive moves' do
      parse_skewb_algorithm("B' L' U'").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to be == 1
    end

    it 'should find a one move layer' do
      parse_skewb_move("U").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be == {
        :white => [parse_skewb_algorithm("U'")]}
    end
    
    it 'should find a two move layer' do
      parse_skewb_algorithm("U R").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to be == {
        :white => [parse_skewb_algorithm("R' U'")]}
    end
    
    it 'should not find a layer that takes too many moves' do
      parse_skewb_algorithm("U R").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be == {}
    end
    
    it 'should find multiple solutions if applicable' do
      parse_skewb_algorithm("B L'").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to be == {
        :white => [parse_skewb_algorithm("L B'")]}
    end
    
  end

  context 'when unrestricted' do
    let (:layer_finder) { SkewbLayerFinder.new }
    
    it 'should find an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to be == {
        :yellow => [Algorithm.empty],
        :red => [Algorithm.empty],
        :green => [Algorithm.empty],
        :blue => [Algorithm.empty],
        :orange => [Algorithm.empty],
        :white => [Algorithm.empty]}
    end
    
    it 'should find a one move layer' do
      parse_skewb_move("U").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be == {
        :yellow => [parse_skewb_algorithm("U'")],
        :red => [parse_skewb_algorithm("U'")],
        :green => [parse_skewb_algorithm("U'")],
        :blue => [parse_skewb_algorithm("U'")],
        :orange => [parse_skewb_algorithm("U'")],
        :white => [parse_skewb_algorithm("U'")]}
    end
    
    it 'should find a two move layer' do
      parse_skewb_algorithm("U R").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to be == {
        :yellow => [parse_skewb_algorithm("R' U'")],
        :red => [parse_skewb_algorithm("R' U'")],
        :green => [parse_skewb_algorithm("R' U'")],
        :blue => [parse_skewb_algorithm("R' U'")],
        :orange => [parse_skewb_algorithm("R' U'")],
        :white => [parse_skewb_algorithm("R' U'")]}
    end
    
    it 'should not find a layer that takes too many moves' do
      parse_skewb_algorithm("U R").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be == {}
    end
    
    it 'should find multiple solutions if applicable' do
      parse_skewb_algorithm("B L'").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to be == {
        :yellow => [parse_skewb_algorithm("L B'")],
        :red => [parse_skewb_algorithm("B' L"), parse_skewb_algorithm("L B'")],
        :green => [parse_skewb_algorithm("L B'")],
        :blue => [parse_skewb_algorithm("L B'")],
        :orange => [parse_skewb_algorithm("L B'"), parse_skewb_algorithm("U' L")],
        :white => [parse_skewb_algorithm("L B'")]}
    end
    
  end
  
end
