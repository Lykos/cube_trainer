# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg, type: :model do
  let(:alg_set) do
    alg_spreadsheet.alg_sets.create!(
      mode_type: ModeType.find_by!(key: :edge_commutators),
      sheet_title: 'UF',
      buffer: uf
    )
  end

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { alg_set.algs }
  end
end
