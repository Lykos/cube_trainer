# frozen_string_literal: true

require 'twisty_puzzles/parser'

describe AbstractMove do
  

  it 'sorts moves by type then face then direction' do
    expect(parse_algorithm('U') < parse_algorithm('M')).to be(true)
    expect(parse_algorithm('U') < parse_algorithm('F')).to be(true)
    expect(parse_algorithm('U') < parse_algorithm("U'")).to be(true)
  end
end
