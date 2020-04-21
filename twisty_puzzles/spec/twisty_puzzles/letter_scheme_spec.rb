# frozen_string_literal: true

require 'twisty_puzzles/cube'
require 'twisty_puzzles/letter_scheme'

describe TwistyPuzzles::LetterScheme do |_clazz|
  let(:letter_scheme) { BernhardTwistyPuzzles::LetterScheme.new }
  let(:letter) { letter_scheme.alphabet.sample }

  it 'finds the corner with the right letter' do
    corner = letter_scheme.for_letter(Corner, letter)
    expect(letter_scheme.letter(corner)).to be == letter
  end

  it 'finds the edge with the right letter' do
    edge = letter_scheme.for_letter(Edge, letter)
    expect(letter_scheme.letter(edge)).to be == letter
  end

  it 'finds the wing with the right letter' do
    wing = letter_scheme.for_letter(Wing, letter)
    expect(letter_scheme.letter(wing)).to be == letter
  end

  it 'finds the midge with the right letter' do
    midge = letter_scheme.for_letter(Midge, letter)
    expect(letter_scheme.letter(midge)).to be == letter
  end

  it 'finds the tcenter with the right letter' do
    tcenter = letter_scheme.for_letter(TCenter, letter)
    expect(letter_scheme.letter(tcenter)).to be == letter
  end

  it 'finds the xcenter with the right letter' do
    xcenter = letter_scheme.for_letter(XCenter, letter)
    expect(letter_scheme.letter(xcenter)).to be == letter
  end
end
