# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

# rubocop:disable Metrics/BlockLength
shared_examples 'alg_like' do
  include TwistyPuzzles

  include_context 'with alg spreadsheet'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }

  describe '#valid?' do
    it 'returns true for a valid alg' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, df, ub]),
        alg: "M' U2 M U2"
      )
      expect(alg).to be_valid
    end

    it 'returns false if the case starts with a twisted version of the buffer' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([fu, df, ub]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('buffer')
    end

    it 'returns false if the case starts with a different piece than the buffer' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([df, ub, uf]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('buffer')
    end

    it 'returns false if the case twists' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, df, ub], 2),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:case_key].first).to include('twist')
    end

    it 'returns false if the algorithm cannot be parsed' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, ub, df]),
        alg: 'asdfadsfasfd'
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:alg].first).not_to be_empty
    end

    it 'returns false if the algorithm is for a different case' do
      alg = owning_set_alg_likes.new(
        case_key: TwistyPuzzles::PartCycle.new([uf, ub, df]),
        alg: "M' U2 M U2"
      )
      expect(alg).not_to be_valid
      expect(alg.errors.messages[:alg].first).not_to be_empty
    end
  end
end
# rubocop:enable Metrics/BlockLength
