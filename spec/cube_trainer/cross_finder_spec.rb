# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/cross_finder'

include CubeTrainer

describe CrossFinder do
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_state) { color_scheme.solved_cube_state(3) }
  let(:cross_finder) { CrossFinder.new }

  it 'should find an existing cross' do
    expect(cross_finder.find_cross(cube_state, 0).extract_algorithms).to be == {
      yellow: [Algorithm.empty],
      red: [Algorithm.empty],
      green: [Algorithm.empty],
      blue: [Algorithm.empty],
      orange: [Algorithm.empty],
      white: [Algorithm.empty]
    }
  end

  it 'should not find a cross that takes too many moves' do
    parse_algorithm('U R F').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be == {}
  end

  it 'should find a one move cross' do
    parse_algorithm('U R').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be == {
      blue: [parse_algorithm('U\'')],
      white: [parse_algorithm('R\'')]
    }
  end
end
