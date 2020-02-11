require 'cube_trainer/core/cube'
require 'cube_trainer/letter_scheme'

describe LetterScheme do |clazz|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:letter) { letter_scheme.alphabet.sample }

  it 'should find the corner with the right letter' do
    corner = letter_scheme.for_letter(Corner, letter)
    expect(letter_scheme.letter(corner)).to be == letter
  end

  it 'should find the edge with the right letter' do
    edge = letter_scheme.for_letter(Edge, letter)
    expect(letter_scheme.letter(edge)).to be == letter
  end

  it 'should find the wing with the right letter' do
    wing = letter_scheme.for_letter(Wing, letter)
    expect(letter_scheme.letter(wing)).to be == letter
  end

  it 'should find the midge with the right letter' do
    midge = letter_scheme.for_letter(Midge, letter)
    expect(letter_scheme.letter(midge)).to be == letter
  end

  it 'should find the tcenter with the right letter' do
    tcenter = letter_scheme.for_letter(TCenter, letter)
    expect(letter_scheme.letter(tcenter)).to be == letter
  end

  it 'should find the xcenter with the right letter' do
    xcenter = letter_scheme.for_letter(XCenter, letter)
    expect(letter_scheme.letter(xcenter)).to be == letter
  end
end


