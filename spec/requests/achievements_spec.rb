require 'rails_helper'
require 'fixtures'

RSpec.describe "Achievements", type: :request do
  include_context :user

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get "/achievements", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expected_achievements = Achievement::ALL.map(&:to_simple).map do |m|
        m[:key] = m[:key].to_s
        m.transform_keys!(&:to_s)
      end
      expect(parsed_body).to eq(expected_achievements)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/achievements/fake", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expected_achievement = Achievement.find_by_key(:fake).to_simple
      expected_achievement[:key] = expected_achievement[:key].to_s
      expected_achievement.transform_keys!(&:to_s)
      expect(parsed_body).to eq(expected_achievement)
    end

    it 'returns not found for unknown achievements' do
      get "/achievements/143432332"
      expect(response).to have_http_status(:not_found)
    end
  end
end
