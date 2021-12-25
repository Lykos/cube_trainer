# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

RSpec.describe AlgSet, type: :model do
  include TwistyPuzzles

  include_context 'with alg spreadsheet'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols([:U, :F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols([:F, :U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols([:D, :F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols([:U, :B]) }
  let(:algorithm) { parse_algorithm("M' U2 M U2") }

  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      mode_type: ModeType.find_by!(key: :edge_commutators),
      sheet_title: 'UF',
      buffer: uf
    )
  end

  let(:alg) do
    alg_set.algs.new(
      case_key: TwistyPuzzles::PartCycle.new([uf, df, ub]),
      alg: algorithm,
    )
  end

  describe '#alg' do
    it 'finds an algorithm for the given case' do
      alg_set.algorithm(TwistyPuzzles::PartCycle.new([uf, df, ub])).to eq(algorithm)
    end

    it 'finds an algorithm for the given case based on its inverse' do
      alg_set.algorithm(TwistyPuzzles::PartCycle.new([uf, ub, df])).to eq(algorithm.inverse)
    end
  end
end
