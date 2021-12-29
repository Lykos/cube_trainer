# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Users', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #name_or_email_exists?' do
    it 'returns true if a user exists' do
      get '/api/name_or_email_exists', params: { name_or_email: user.name }, headers: user_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it 'returns true if an email exists' do
      get '/api/name_or_email_exists', params: { name_or_email: user.email }, headers: user_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it "returns false if an name/email doesn't exist" do
      get '/api/name_or_email_exists', params: { name_or_email: 'grmlefex' }, headers: user_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(false)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/user', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns unauthorized' do
      get '/api/user'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
