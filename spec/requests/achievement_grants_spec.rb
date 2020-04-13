require 'rails_helper'
require 'fixtures'

RSpec.describe "AchievementGrants", type: :request do
  include_context :user
  include_context :admin
  include_context :eve
  include_context :achievement_grant

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success' do
      achievement_grant
      get "/users/#{user.id}/achievement_grants", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement_grant = parsed_body.any? do |p|
        Achievement.new(p['achievement']) == achievement && p['id'] == achievement_grant.id
      end
      expect(contains_achievement_grant).to be(true)
    end

    it 'returns http success for admin' do
      achievement_grant
      post "/login", params: { username: admin.name, password: admin.password }
      get "/users/#{user.id}/achievement_grants", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement_grant = parsed_body.any? do |p|
        Achievement.new(p['achievement']) == achievement && p['id'] == achievement_grant.id
      end
      expect(contains_achievement_grant).to be(true)
    end

    it 'returns nothing for another user' do
      achievement_grant
      post "/login", params: { username: eve.name, password: eve.password }
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
      expect(Achievement.new(parsed_body['achievement'])).to eq(achievement)
    end

    it 'returns http success for admin' do
      post "/login", params: { username: admin.name, password: admin.password }
      get "/users/#{user.id}/achievement_grants/#{achievement_grant.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(achievement_grant.id)
      expect(Achievement.new(parsed_body['achievement'])).to eq(achievement)
    end

    it 'returns not found for unknown achievement_grants' do
      get "/users/#{user.id}/achievement_grants/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post "/login", params: { username: eve.name, password: eve.password }
      get "/users/#{user.id}/achievement_grants/#{achievement_grant.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
