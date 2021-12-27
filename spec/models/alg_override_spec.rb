# frozen_string_literal: true

require 'rails_helper'
require_relative 'alg_like_shared_examples'

RSpec.describe Alg, type: :model do
  include_context 'with mode'

  it_behaves_like 'alg_like' do
    let(:owning_set_alg_likes) { mode.alg_overrides }
  end
end
