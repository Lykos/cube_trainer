# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dumps', type: :request do
  include_context 'with user abc'
  include_context 'with headers'
  include_context 'with user auth headers'

  describe 'GET /api/dump' do
    it 'returns http success' do
      get '/api/dump', headers: user_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq({})
    end

    it 'returns not found when not logged in' do
      get '/api/dump', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
