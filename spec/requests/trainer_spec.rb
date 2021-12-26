# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Trainer', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with mode'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #random_case' do
    it 'returns http success' do
      get "/api/trainer/#{mode.id}/random_case", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to contain_exactly('case_key', 'case_name', 'setup', 'alg')
    end

    it 'returns http success with cached ids' do
      get "/api/trainer/#{mode.id}/random_case", headers: user_headers
      expect(response).to have_http_status(:success)
      case_key = JSON.parse(response.body)['case_key']
      get "/api/trainer/#{mode.id}/random_case", headers: user_headers, params: { cached_case_keys: [case_key] }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to contain_exactly('case_key', 'case_name', 'setup', 'alg')
      expect(parsed_body['case_key']).not_to eq(case_key)
    end

    it 'returns not found for unknown modes' do
      get '/api/trainer/143432332/random_case', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      get "/api/trainer/#{mode.id}/random_case", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
