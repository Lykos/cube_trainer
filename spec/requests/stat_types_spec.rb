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
      parsed_body = JSON.parse(response.body).map(&:deep_symbolize_keys)
      expect(parsed_body).to include({ id: 'progress', name: 'Progress', description: nil })
      expect(parsed_body).to include({ id: 'success_rates', name: 'Success Rates', description: 'Success Rates in the last 5, 12 50, etc. solves.' })
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/stat_types/averages', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_body).to eq({ id: 'averages', name: 'Averages', description: 'Averages like ao5, ao12, ao50, etc..' })
    end

    it 'returns not found for unknown stat types' do
      get '/api/stat_types/143432332'
      expect(response).to have_http_status(:not_found)
    end
  end
end
