# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/letter_scheme'

describe LetterScheme do |_clazz|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:letter) { letter_scheme.alphabet.sample }

  it 'finds the corner with the right letter' do
    corner = letter_scheme.for_letter(Core::Corner, letter)
    expect(letter_scheme.letter(corner)).to be == letter
  end

  it 'finds the edge with the right letter' do
    edge = letter_scheme.for_letter(Core::Edge, letter)
    expect(letter_scheme.letter(edge)).to be == letter
  end

  it 'finds the wing with the right letter' do
    wing = letter_scheme.for_letter(Core::Wing, letter)
    expect(letter_scheme.letter(wing)).to be == letter
  end

  it 'finds the midge with the right letter' do
    midge = letter_scheme.for_letter(Core::Midge, letter)
    expect(letter_scheme.letter(midge)).to be == letter
  end

  it 'finds the tcenter with the right letter' do
    tcenter = letter_scheme.for_letter(Core::TCenter, letter)
    expect(letter_scheme.letter(tcenter)).to be == letter
  end

  it 'finds the xcenter with the right letter' do
    xcenter = letter_scheme.for_letter(Core::XCenter, letter)
    expect(letter_scheme.letter(xcenter)).to be == letter
  end
end
