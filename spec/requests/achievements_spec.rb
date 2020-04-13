require 'rails_helper'
require 'fixtures'

RSpec.describe "Achievements", type: :request do
  include_context :user
  include_context :achievement

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success' do
      achievement
      get "/achievements", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_achievement = parsed_body.any? { |p| Achievement.new(p) == achievement }
      expect(contains_achievement).to be(true)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/achievements/#{achievement.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(Achievement.new(parsed_body)).to eq(achievement)
    end

    it 'returns not found for unknown achievements' do
      get "/achievements/143432332"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/achievements/#{achievement.id}new"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get "/achievements/#{achievement.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/achievements", params: {
             achievement: {
               name: 'test_achievement2',
               achievement_type: :fake
             }
           }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(achievement.id)
      expect(Achievement.find(parsed_body['id']).name).to eq('test_achievement2')
    end

    it 'returns bad request for invalid achievements' do
      post "/achievements", params: {
             achievement: {
               name: 'test_achievement2',
               achievement_type: :fake,
               param: 1
             }
           }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/achievements/#{achievement.id}", params: { achievement: { name: 'dodo' } }
      expect(response).to have_http_status(:success)
      achievement.reload
      expect(achievement.name).to eq('dodo')
      expect(achievement.achievement_type.name).to eq(:fake)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/achievements/#{achievement.id}", params: { achievement: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Achievement.find(achievement.id).name).to eq('achievement')
    end

    it 'returns not found for unknown achievements' do
      put "/achievements/143432332", params: { achievement: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/achievements/#{achievement.id}"
      expect(response).to have_http_status(:success)
      expect(Achievement.exists?(achievement.id)).to be(false)
    end

    it 'returns not found for unknown achievements' do
      delete "/achievements/143432332"
      expect(response).to have_http_status(:not_found)
    end
  end
end
