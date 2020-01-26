require 'cube_trainer/commutator_reverse_engineer'
require 'cube_trainer/cube'
require 'cube_trainer/parser'
require 'cube_trainer/color_scheme'
require 'cube_trainer/letter_scheme'

include CubeTrainer

describe CommutatorReverseEngineer do

  let (:letter_scheme) { BernhardLetterScheme.new }
  let (:cube_size) { 3 }
  let (:engineer) { CommutatorReverseEngineer.new(part_type, buffer, letter_scheme, cube_size) }

  context 'for corners' do
    let (:part_type) { Corner }
    let (:buffer) { Corner.for_face_symbols([:U, :L, :B]) }

    it "should find the letters of ig" do
      alg = parse_commutator("[L', U R U']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['i', 'g'])
    end

    it "should find the letters of gi" do
      alg = parse_commutator("[U R U', L']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['g', 'i'])
    end

    it "should find the letters of tg" do
      alg = parse_commutator("[L', U R' U']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['t', 'g'])
    end

    it "should find the letters of gt" do
      alg = parse_commutator("[U R' U', L']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['g', 't'])
    end

    it "should find the letters of it" do
      alg = parse_commutator("[D U R U' : [D', R' U R]]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['i', 't'])
    end

    it "should find the letters of ti" do
      alg = parse_commutator("[D U R U' : [R' U R, D']]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['t', 'i'])
    end

  end

  context 'for edges' do
    let (:part_type) { Edge }
    let (:buffer) { Edge.for_face_symbols([:U, :F]) }

    it "should find the letters of a simple alg" do
      alg = parse_commutator("[R' F R, S]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['i', 'c'])
    end

  end

end
