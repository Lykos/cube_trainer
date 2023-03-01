# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AchievementGrants' do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with achievement grant'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #index' do
    it 'returns http success' do
      achievement_grant
      get '/api/achievement_grants', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body.map(&:deep_symbolize_keys)
      expect(parsed_body.length).to be >= 1
      expect(parsed_body).to include(include(id: achievement_grant.id, achievement: { id: 'fake', name: 'Fake', description: 'Fake achievement for tests.' }))
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/achievement_grants/#{achievement_grant.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body.deep_symbolize_keys
      expect(parsed_body).to include(id: achievement_grant.id, achievement: { id: 'fake', name: 'Fake', description: 'Fake achievement for tests.' })
    end

    it 'returns not found for unknown achievement_grants' do
      get '/api/achievement_grants/143432332', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/achievement_grants/#{achievement_grant.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
