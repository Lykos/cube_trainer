# frozen_string_literal: true

require 'cube_trainer/commutator_reverse_engineer'
require 'twisty_puzzles'

describe CommutatorReverseEngineer do
  include TwistyPuzzles

  let(:cube_size) { 3 }
  let(:engineer) { described_class.new(part_type, buffer, cube_size) }

  context 'with corners' do
    let(:part_type) { TwistyPuzzles::Corner }
    let(:buffer) { part_type.for_face_symbols(%i[U L B]) }
    let(:i) { part_type.for_face_symbols(%i[R B U]) }
    let(:t) { part_type.for_face_symbols(%i[B R D]) }
    let(:g) { part_type.for_face_symbols(%i[F L U]) }

    it 'finds the parts of ig' do
      alg = parse_commutator("[L', U R U']").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, i, g])
    end

    it 'finds the parts of gi' do
      alg = parse_commutator("[U R U', L']").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, g, i])
    end

    it 'finds the parts of tg' do
      alg = parse_commutator("[L', U R' U']").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, t, g])
    end

    it 'finds the parts of gt' do
      alg = parse_commutator("[U R' U', L']").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, g, t])
    end

    it 'finds the parts of it' do
      alg = parse_commutator("[D U R U' : [D', R' U R]]").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, i, t])
    end

    it 'finds the parts of ti' do
      alg = parse_commutator("[D U R U' : [R' U R, D']]").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, t, i])
    end
  end

  context 'with edges' do
    let(:part_type) { TwistyPuzzles::Edge }
    let(:buffer) { part_type.for_face_symbols(%i[U F]) }
    let(:i) { part_type.for_face_symbols(%i[R U]) }
    let(:c) { part_type.for_face_symbols(%i[U L]) }

    it 'finds the parts of a simple alg' do
      alg = parse_commutator("[R' F R, S]").algorithm
      expect(engineer.find_part_cycle(alg)).to be == TwistyPuzzles::PartCycle.new([buffer, i, c])
    end
  end
end
