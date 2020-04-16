require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  include_context :user

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET #login' do
    it 'returns http success' do
      get "/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #welcome' do
    it 'returns unauthorized if not logged in' do
      get "/welcome"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #login' do
    it 'returns http success' do
      post "/login", params: { username: user.name, password: user.password }, headers: headers
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized for wrong password' do
      post "/login", params: { username: user.name, password: 'dodo' }, headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #logout' do
    it 'returns http success' do
      post "/login", params: { username: user.name, password: user.password }, headers: headers
      post "/logout", headers: headers
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized if not logged in' do
      post "/logout", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
