# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stats', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with stat'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      Stat.delete_all
      stat
      get "/api/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(stat.id)
      expect(parsed_item['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/api/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/modes/#{mode.id}/stats/#{stat.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(stat.id)
      expect(parsed_body['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for unknown stats' do
      get "/api/modes/#{mode.id}/stats/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/api/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/modes/#{mode.id}/stats/#{stat.id}"
      expect(response).to have_http_status(:success)
      expect(Stat.exists?(stat.id)).to be(false)
    end

    it 'returns not found for unknown stats' do
      delete "/api/modes/#{mode.id}/stats/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      delete "/api/modes/#{mode.id}/stats/#{stat.id}"
      expect(response).to have_http_status(:not_found)
      expect(Stat.exists?(stat.id)).to be(true)
    end
  end
end
