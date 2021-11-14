# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Sessions', type: :request do
  include_context 'with user abc'
  include_context 'with headers'

  describe 'POST #login' do
    it 'returns http success with name' do
      post_login(user)
      expect(response).to have_http_status(:success)
    end

    it 'returns http success with email' do
      post_login(user.email, user.password)
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized for wrong password' do
      post_login(user.name, 'dodo')
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #logout' do
    it 'returns http success' do
      post_login(user)
      post '/api/logout', headers: headers
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized if not logged in' do
      post '/api/logout', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
