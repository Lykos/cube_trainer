# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Achievements' do
  include_context 'with user abc'
  include_context 'with headers'

  describe 'GET #index' do
    it 'returns http success' do
      get '/api/achievements', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).map(&:deep_symbolize_keys)
      expect(parsed_body.length).to eq(Achievement::ALL.length)
      expect(parsed_body).to include({ id: 'fake', name: 'Fake', description: 'Fake achievement for tests.' })
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/achievements/fake', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_body).to eq({ id: 'fake', name: 'Fake', description: 'Fake achievement for tests.' })
    end

    it 'returns not found for unknown achievements' do
      get '/api/achievements/143432332'
      expect(response).to have_http_status(:not_found)
    end
  end
end
