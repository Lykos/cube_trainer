# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/skewb_layer_finder'

describe SkewbLayerFinder do
  include Core
  include Core::CubePrintHelper

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:skewb_state) { color_scheme.solved_skewb_state }

  context 'when restricted' do
    let(:layer_finder) { described_class.new([:white]) }

    it 'finds an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to(be == {
        white: [Core::Algorithm::EMPTY]
      })
    end

    it 'finds the perfect score without moves' do
      expect(layer_finder.state_score(skewb_state)).to(be == 4)
    end

    it 'finds the score after one move' do
      parse_fixed_corner_skewb_algorithm('R').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 3)
    end

    it 'finds the score after two moves that destroy adjacent things' do
      parse_fixed_corner_skewb_algorithm('R U').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds the score after two moves that destroy opposite things' do
      parse_fixed_corner_skewb_algorithm('R L').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds the score after three moves' do
      parse_fixed_corner_skewb_algorithm('R U R').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds the score after three moves' do
      parse_fixed_corner_skewb_algorithm("B' L' U'").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds the score after three destructive moves' do
      parse_fixed_corner_skewb_algorithm('R U B').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 1)
    end

    it 'finds the score after three destructive moves' do
      parse_fixed_corner_skewb_algorithm('R U L').apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 1)
    end

    it 'finds the score after moves that create pseudo adjacent things' do
      parse_sarahs_skewb_algorithm("B R B F'").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 1)
    end

    it 'finds the score for the pseudo solved layer' do
      parse_sarahs_skewb_algorithm("L B' R B' L' B' L'").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds the score for a layer with 3 solved pieces with pseudo adjacency' do
      parse_sarahs_skewb_algorithm("F' R B' R'").apply_to(skewb_state)
      expect(layer_finder.state_score(skewb_state)).to(be == 2)
    end

    it 'finds a one move layer' do
      parse_fixed_corner_skewb_algorithm('U').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to(be == {
        white: [parse_fixed_corner_skewb_algorithm("U'")]
      })
    end

    it 'finds a two move layer' do
      parse_fixed_corner_skewb_algorithm('U R').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to(be == {
        white: [parse_fixed_corner_skewb_algorithm("R' U'")]
      })
    end

    it 'does not find a layer that takes too many moves' do
      parse_fixed_corner_skewb_algorithm('U R').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to(be == {})
    end

    it 'finds multiple solutions if applicable' do
      parse_fixed_corner_skewb_algorithm("B L'").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to(be == {
        white: [parse_fixed_corner_skewb_algorithm("L B'")]
      })
    end
  end

  context 'when unrestricted' do
    let(:layer_finder) { described_class.new }

    it 'finds an existing layer' do
      expect(layer_finder.find_layer(skewb_state, 0).extract_algorithms).to(be == {
        yellow: [Core::Algorithm::EMPTY],
        red: [Core::Algorithm::EMPTY],
        green: [Core::Algorithm::EMPTY],
        blue: [Core::Algorithm::EMPTY],
        orange: [Core::Algorithm::EMPTY],
        white: [Core::Algorithm::EMPTY]
      })
    end

    it 'finds a one move layer' do
      parse_fixed_corner_skewb_algorithm('U').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to(be == {
        yellow: [parse_fixed_corner_skewb_algorithm("U'")],
        red: [parse_fixed_corner_skewb_algorithm("U'")],
        green: [parse_fixed_corner_skewb_algorithm("U'")],
        blue: [parse_fixed_corner_skewb_algorithm("U'")],
        orange: [parse_fixed_corner_skewb_algorithm("U'")],
        white: [parse_fixed_corner_skewb_algorithm("U'")]
      })
    end

    it 'finds a two move layer' do
      parse_fixed_corner_skewb_algorithm('U R').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to(be == {
        yellow: [parse_fixed_corner_skewb_algorithm("R' U'")],
        red: [parse_fixed_corner_skewb_algorithm("R' U'")],
        green: [parse_fixed_corner_skewb_algorithm("R' U'")],
        blue: [parse_fixed_corner_skewb_algorithm("R' U'")],
        orange: [parse_fixed_corner_skewb_algorithm("R' U'")],
        white: [parse_fixed_corner_skewb_algorithm("R' U'")]
      })
    end

    it 'does not find a layer that takes too many moves' do
      parse_fixed_corner_skewb_algorithm('U R').apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 1).extract_algorithms).to(be == {})
    end

    it 'finds multiple solutions if applicable' do
      parse_fixed_corner_skewb_algorithm("B L'").apply_to(skewb_state)
      expect(layer_finder.find_layer(skewb_state, 2).extract_algorithms).to(be == {
        yellow: [parse_fixed_corner_skewb_algorithm("L B'")],
        red: [parse_fixed_corner_skewb_algorithm("L B'")],
        green: [parse_fixed_corner_skewb_algorithm("B' L"), parse_fixed_corner_skewb_algorithm("L B'")],
        blue: [parse_fixed_corner_skewb_algorithm("L B'"), parse_fixed_corner_skewb_algorithm("U' L")],
        orange: [parse_fixed_corner_skewb_algorithm("L B'")],
        white: [parse_fixed_corner_skewb_algorithm("L B'")]
      })
    end
  end
end
