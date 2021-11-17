# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Achievements', type: :request do
  include_context 'with user abc'
  include_context 'with headers'

  describe 'GET #index' do
    it 'returns http success' do
      get '/api/achievements', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(Achievement::ALL.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/achievements/fake', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(Achievement.find_by(key: :fake).to_simple)
    end

    it 'returns not found for unknown achievements' do
      get '/api/achievements/143432332'
      expect(response).to have_http_status(:not_found)
    end
  end
end
