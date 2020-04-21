# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/cross_finder'

describe CrossFinder do
  include TwistyPuzzles

  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:cube_state) { color_scheme.solved_cube_state(3) }
  let(:cross_finder) { described_class.new }

  it 'finds an existing cross' do
    expect(cross_finder.find_cross(cube_state, 0).extract_algorithms).to eq(
      {
        yellow: [TwistyPuzzles::Algorithm::EMPTY],
        red: [TwistyPuzzles::Algorithm::EMPTY],
        green: [TwistyPuzzles::Algorithm::EMPTY],
        blue: [TwistyPuzzles::Algorithm::EMPTY],
        orange: [TwistyPuzzles::Algorithm::EMPTY],
        white: [TwistyPuzzles::Algorithm::EMPTY]
      }
    )
  end

  it 'does not find a cross that takes too many moves' do
    parse_algorithm('U R F').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to be_empty
  end

  it 'finds a one move cross' do
    parse_algorithm('U R').apply_to(cube_state)
    expect(cross_finder.find_cross(cube_state, 1).extract_algorithms).to eq(
      {
        blue: [parse_algorithm("U'")],
        white: [parse_algorithm("R'")]
      }
    )
  end
end
