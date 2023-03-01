# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Users' do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #show' do
    it 'returns http success' do
      get '/api/user', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns unauthorized' do
      get '/api/user'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
