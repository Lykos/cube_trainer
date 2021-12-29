# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with stat'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #index' do
    it 'returns http success' do
      Stat.delete_all
      stat
      get "/api/training_sessions/#{training_session.id}/stats", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(stat.id)
      expect(parsed_item['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for another user' do
      get "/api/training_sessions/#{training_session.id}/stats", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/training_sessions/#{training_session.id}/stats/#{stat.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(stat.id)
      expect(parsed_body['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for unknown stats' do
      get "/api/training_sessions/#{training_session.id}/stats/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/training_sessions/#{training_session.id}/stats", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/training_sessions/#{training_session.id}/stats/#{stat.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      expect(Stat.exists?(stat.id)).to be(false)
    end

    it 'returns not found for unknown stats' do
      delete "/api/training_sessions/#{training_session.id}/stats/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      delete "/api/training_sessions/#{training_session.id}/stats/#{stat.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
      expect(Stat.exists?(stat.id)).to be(true)
    end
  end
end
