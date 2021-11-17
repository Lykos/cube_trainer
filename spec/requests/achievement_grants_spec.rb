# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AchievementGrants', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with achievement grant'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  let(:expected_achievement) do
    achievement = Achievement.find_by(key: :fake).to_simple
    achievement[:key] = achievement[:key].to_s
    achievement.transform_keys!(&:to_s)
    achievement
  end

  describe 'GET #index' do
    it 'returns http success' do
      achievement_grant
      get '/api/achievement_grants', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement_grant =
        parsed_body.any? do |p|
          p['achievement'] == expected_achievement && p['id'] == achievement_grant.id
        end
      expect(contains_achievement_grant).to be(true)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/achievement_grants/#{achievement_grant.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(achievement_grant.id)
      expect(parsed_body['achievement']).to eq(expected_achievement)
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
