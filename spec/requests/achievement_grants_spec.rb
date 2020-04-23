# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'
require 'requests/requests_spec_helper'

RSpec.describe 'AchievementGrants', type: :request do
  include_context :user
  include_context :admin
  include_context :eve
  include_context :achievement_grant
  include_context :headers

  before(:each) do
    post_login(user)
  end

  let(:expected_achievement) do
    achievement = Achievement.find_by(key: :fake).to_simple
    achievement[:key] = achievement[:key].to_s
    achievement.transform_keys!(&:to_s)
    achievement
  end

  describe 'GET #index' do
    it 'returns http success' do
      achievement_grant
      get "/users/#{user.id}/achievement_grants", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement_grant =
        parsed_body.any? do |p|
          p['achievement'] == expected_achievement && p['id'] == achievement_grant.id
        end
      expect(contains_achievement_grant).to be(true)
    end

    it 'returns http success for admin' do
      achievement_grant
      post_login(admin.name, admin.password)
      get "/users/#{user.id}/achievement_grants", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement_grant =
        parsed_body.any? do |p|
          p['achievement'] == expected_achievement && p['id'] == achievement_grant.id
        end
      expect(contains_achievement_grant).to be(true)
    end

    it 'returns nothing for another user' do
      achievement_grant
      post_login(eve.name, eve.password)
      get "/users/#{user.id}/achievement_grants", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/users/#{user.id}/achievement_grants/#{achievement_grant.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(achievement_grant.id)
      expect(parsed_body['achievement']).to eq(expected_achievement)
    end

    it 'returns http success for admin' do
      post_login(admin.name, admin.password)
      get "/users/#{user.id}/achievement_grants/#{achievement_grant.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(achievement_grant.id)
      expect(parsed_body['achievement']).to eq(expected_achievement)
    end

    it 'returns not found for unknown achievement_grants' do
      get "/users/#{user.id}/achievement_grants/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/users/#{user.id}/achievement_grants/#{achievement_grant.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
