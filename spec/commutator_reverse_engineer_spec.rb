require 'commutator_reverse_engineer'
require 'cube'
require 'parser'
require 'letter_scheme'

include CubeTrainer

describe CommutatorReverseEngineer do

  context 'for corners' do
    let (:part_type) { Corner }
    let (:buffer) { Corner.for_colors([:yellow, :orange, :blue]) }
    let (:cube_size) { 3 }
    let (:engineer) { CommutatorReverseEngineer.new(part_type, buffer, DefaultLetterScheme.new, cube_size) }

    it "should find the letters of a simple alg" do
      alg = parse_commutator("[L', U R U']").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['i', 'g'])
    end

  end

  context 'for edges' do
    let (:part_type) { Edge }
    let (:buffer) { Edge.for_colors([:yellow, :red]) }
    let (:cube_size) { 3 }
    let (:engineer) { CommutatorReverseEngineer.new(part_type, buffer, DefaultLetterScheme.new, cube_size) }

    it "should find the letters of a simple alg" do
      alg = parse_commutator("[R' F R, S]").algorithm
      expect(engineer.find_letter_pair(alg)).to be == LetterPair.new(['i', 'c'])
    end

  end

end
