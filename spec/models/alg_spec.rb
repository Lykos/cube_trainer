# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

RSpec.describe Alg, type: :model do
  include TwistyPuzzles

  include_context 'with alg spreadsheet'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      mode_type: ModeType.find_by!(key: :edge_commutators),
      sheet_title: 'UF',
      buffer: uf
    )
  end

  describe '#valid?' do
    it 'returns true for a valid alg' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, df, ub]),
        alg: "M' U2 M U2"
      )
      expect(alg).to be_valid
    end

    it 'returns false if the case starts with a twisted version of the buffer' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([fu, df, ub]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('buffer')
    end

    it 'returns false if the case starts with a different piece than the buffer' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([df, ub, uf]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('buffer')
    end

    it 'returns false if the case twists' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, df, ub], 2),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('twist')
    end

    it 'returns false if the algorithm cannot be parsed' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, ub, df]),
        alg: 'asdfadsfasfd'
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:alg].first).not_to be_empty
    end

    it 'returns false if the algorithm is for a different case' do
      alg = alg_set.algs.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, ub, df]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:alg].first).not_to be_empty
    end
  end
end
