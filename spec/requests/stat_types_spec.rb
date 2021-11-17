# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'StatTypes', type: :request do
  include_context 'with user abc'
  include_context 'with headers'

  describe 'GET #index' do
    it 'returns http success' do
      get '/api/stat_types', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(StatType::ALL.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/stat_types/averages', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(StatType.find_by(key: :averages).to_simple)
    end

    it 'returns not found for unknown stat types' do
      get '/api/stat_types/143432332'
      expect(response).to have_http_status(:not_found)
    end
  end
end
