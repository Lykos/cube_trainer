# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/skewb_notation'
require 'cube_trainer/skewb_layer_finder'

describe SkewbLayerFinder do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:skewb_state) { color_scheme.solved_skewb_state }
  let(:sarah) { Core::SkewbNotation.sarah }
  let(:fixed_corner) { Core::SkewbNotation.fixed_corner }

  context 'when restricted' do
    let(:layer_finder) { described_class.new([:white]) }

    it 'finds an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to eq(
        {
          white: [Core::Algorithm::EMPTY]
        }
      )
    end

    it 'finds the perfect score without moves' do
      expect(layer_finder.state_score(skewb_state)).to eq(4)
    end

    it 'finds the score after one move' do
      parse_skewb_algorithm('R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(3)
    end

    it 'finds the score after two moves that destroy adjacent things' do
      parse_skewb_algorithm('R U', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds the score after two moves that destroy opposite things' do
      parse_skewb_algorithm('R L', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds the score after three moves' do
      parse_skewb_algorithm('R U R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds the score after three moves' do
      parse_skewb_algorithm("B' L' U'", fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds the score after three destructive moves' do
      parse_skewb_algorithm('R U B', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(1)
    end

    it 'finds the score after three destructive moves' do
      parse_skewb_algorithm('R U L', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(1)
    end

    it 'finds the score after moves that create pseudo adjacent things' do
      parse_skewb_algorithm("B R B F'", sarah).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(1)
    end

    it 'finds the score for the pseudo solved layer' do
      parse_skewb_algorithm("L B' R B' L' B' L'", sarah).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds the score for a layer with 3 solved pieces with pseudo adjacency' do
      parse_skewb_algorithm("F' R B' R'", sarah).apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to eq(2)
    end

    it 'finds a one move layer' do
      parse_skewb_algorithm('U', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to eq(
        {
          white: [parse_skewb_algorithm("U'", fixed_corner)]
        }
      )
    end

    it 'finds a two move layer' do
      parse_skewb_algorithm('U R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to eq(
        {
          white: [parse_skewb_algorithm("R' U'", fixed_corner)]
        }
      )
    end

    it 'does not find a layer that takes too many moves' do
      parse_skewb_algorithm('U R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be_empty
    end

    it 'finds multiple solutions if applicable' do
      parse_skewb_algorithm("B L'", fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to eq(
        {
          white: [parse_skewb_algorithm("L B'", fixed_corner)]
        }
      )
    end
  end

  context 'when unrestricted' do
    let(:layer_finder) { described_class.new }

    it 'finds an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to eq(
        {
          yellow: [Core::Algorithm::EMPTY],
          red: [Core::Algorithm::EMPTY],
          green: [Core::Algorithm::EMPTY],
          blue: [Core::Algorithm::EMPTY],
          orange: [Core::Algorithm::EMPTY],
          white: [Core::Algorithm::EMPTY]
        }
      )
    end

    it 'finds a one move layer' do
      parse_skewb_algorithm('U', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to eq(
        {
          yellow: [parse_skewb_algorithm("U'", fixed_corner)],
          red: [parse_skewb_algorithm("U'", fixed_corner)],
          green: [parse_skewb_algorithm("U'", fixed_corner)],
          blue: [parse_skewb_algorithm("U'", fixed_corner)],
          orange: [parse_skewb_algorithm("U'", fixed_corner)],
          white: [parse_skewb_algorithm("U'", fixed_corner)]
        }
      )
    end

    it 'finds a two move layer' do
      parse_skewb_algorithm('U R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to eq(
        {
          yellow: [parse_skewb_algorithm("R' U'", fixed_corner)],
          red: [parse_skewb_algorithm("R' U'", fixed_corner)],
          green: [parse_skewb_algorithm("R' U'", fixed_corner)],
          blue: [parse_skewb_algorithm("R' U'", fixed_corner)],
          orange: [parse_skewb_algorithm("R' U'", fixed_corner)],
          white: [parse_skewb_algorithm("R' U'", fixed_corner)]
        }
      )
    end

    it 'does not find a layer that takes too many moves' do
      parse_skewb_algorithm('U R', fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to be == {}
    end

    it 'finds multiple solutions if applicable' do
      parse_skewb_algorithm("B L'", fixed_corner).apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms.transform_values(&:sort)).to eq(
        {
          yellow: [parse_skewb_algorithm("L B'", fixed_corner)],
          red: [parse_skewb_algorithm("L B'", fixed_corner)],
          green: [parse_skewb_algorithm("B' L", fixed_corner), parse_skewb_algorithm("L B'", fixed_corner)].sort,
          blue: [parse_skewb_algorithm("L B'", fixed_corner), parse_skewb_algorithm("U' L", fixed_corner)].sort,
          orange: [parse_skewb_algorithm("L B'", fixed_corner)],
          white: [parse_skewb_algorithm("L B'", fixed_corner)]
        }
      )
    end
  end
end
