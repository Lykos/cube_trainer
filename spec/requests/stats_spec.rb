# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'

RSpec.describe 'Stats', type: :request do
  include_context :user
  include_context :eve
  include_context :stat
  include_context :headers

  before(:each) do
    login(user.name, user.password)
  end

  describe 'GET #index' do
    it 'returns http success' do
      Stat.delete_all
      stat
      get "/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(stat.id)
      expect(parsed_item['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for another user' do
      login(eve.name, eve.password)
      get "/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/modes/#{mode.id}/stats/#{stat.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(stat.id)
      expect(parsed_body['stat_type']['key']).to eq(stat.stat_type.key.to_s)
    end

    it 'returns not found for unknown stats' do
      get "/modes/#{mode.id}/stats/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      login(eve.name, eve.password)
      get "/modes/#{mode.id}/stats", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/modes/#{mode.id}/stats/#{stat.id}"
      expect(response).to have_http_status(:success)
      expect(Stat.exists?(stat.id)).to be(false)
    end

    it 'returns not found for unknown stats' do
      delete "/modes/#{mode.id}/stats/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      login(eve.name, eve.password)
      delete "/modes/#{mode.id}/stats/#{stat.id}"
      expect(response).to have_http_status(:not_found)
      expect(Stat.exists?(stat.id)).to be(true)
    end
  end
end
