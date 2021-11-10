# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'
require 'requests/requests_spec_helper'
require 'matchers'

RSpec.describe 'ModeTypes', type: :request do
  include_context 'with user abc'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get '/api/mode_types', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(ModeType.all.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    let(:mode_type) { ModeType.all.sample }

    it 'returns http success' do
      get "/api/mode_types/#{mode_type.key}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(mode_type.to_simple)
    end

    it 'returns not found for unknown mode types' do
      get '/api/modes/non_existing'
      expect(response).to have_http_status(:not_found)
    end
  end
end
