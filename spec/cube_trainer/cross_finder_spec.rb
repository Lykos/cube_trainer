# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/cross_finder'

describe CrossFinder do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_state) { color_scheme.solved_cube_state(3) }
  let(:cross_finder) { described_class.new }

  it 'finds an existing cross' do
    expect(cross_finder.find_cross(cube_state, 0).extract_algorithms).to eq({
      yellow: [Core::Algorithm::EMPTY],
      red: [Core::Algorithm::EMPTY],
      green: [Core::Algorithm::EMPTY],
      blue: [Core::Algorithm::EMPTY],
      orange: [Core::Algorithm::EMPTY],
      white: [Core::Algorithm::EMPTY]
    })
  end

  it 'does not find a cross that takes too many moves' do
    parse_algorithm('U R F').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be_empty
  end

  it 'finds a one move cross' do
    parse_algorithm('U R').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to eq({
      blue: [parse_algorithm("U'")],
      white: [parse_algorithm("R'")]
    })
  end
end
