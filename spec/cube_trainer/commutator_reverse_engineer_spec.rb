# frozen_string_literal: true

require 'cube_trainer/commutator_reverse_engineer'
require 'twisty_puzzles'

describe CommutatorReverseEngineer do
  include TwistyPuzzles

  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:cube_size) { 3 }
  let(:engineer) { described_class.new(part_type, buffer, letter_scheme, cube_size) }

  context 'for corners' do
    let(:part_type) { TwistyPuzzles::Corner }
    let(:buffer) { TwistyPuzzles::Corner.for_face_symbols(%i[U L B]) }

    it 'finds the letters of ig' do
      alg = parse_commutator("[L', U R U']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[i g])
    end

    it 'finds the letters of gi' do
      alg = parse_commutator("[U R U', L']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[g i])
    end

    it 'finds the letters of tg' do
      alg = parse_commutator("[L', U R' U']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[t g])
    end

    it 'finds the letters of gt' do
      alg = parse_commutator("[U R' U', L']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[g t])
    end

    it 'finds the letters of it' do
      alg = parse_commutator("[D U R U' : [D', R' U R]]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[i t])
    end

    it 'finds the letters of ti' do
      alg = parse_commutator("[D U R U' : [R' U R, D']]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[t i])
    end
  end

  context 'for edges' do
    let(:part_type) { TwistyPuzzles::Edge }
    let(:buffer) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }

    it 'finds the letters of a simple alg' do
      alg = parse_commutator("[R' F R, S]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(%w[i c])
    end
  end
end
