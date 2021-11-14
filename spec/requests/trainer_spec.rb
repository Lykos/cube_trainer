# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Trainer', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with mode'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to eq(%w[id representation hints])
      expect(Input.find(parsed_body['id'])).not_to be(nil)
    end

    it 'returns http success with cached ids' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      expect(response).to have_http_status(:success)
      id = JSON.parse(response.body)['id']
      post "/api/trainer/#{mode.id}/inputs", params: { cached_input_ids: [id] }, headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to eq(%w[id representation hints])
      expect(Input.find(parsed_body['id'])).not_to be(nil)
      expect(parsed_body['id']).not_to eq(id)
    end

    it 'returns not found for unknown modes' do
      post '/api/trainer/143432332/inputs', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      delete "/api/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:success)
      expect(Input.exists?(id: input_id)).to be(false)
    end

    it 'returns not found for unknown modes' do
      delete '/api/trainer/143432332/inputs/1', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for unknown inputs' do
      delete '/api/trainer/1/inputs/1243943', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post_login(eve.name, eve.password)
      delete "/api/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:not_found)
      expect(Input.exists?(id: input_id)).to be(true)
    end
  end

  describe 'POST #stop' do
    it 'returns http success' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/api/trainer/#{mode.id}/inputs/#{input_id}", params: { partial_result: { time_s: 10 } }
      expect(response).to have_http_status(:success)
      expect(Input.find(input_id).result.time).to eq(10.seconds)
    end

    it 'returns not found for unknown modes' do
      post '/api/trainer/143432332/inputs/1', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for unknown inputs' do
      post '/api/trainer/1/inputs/1243943', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request if no partial result is given' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/api/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if no numeric time is given' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/api/trainer/#{mode.id}/inputs/#{input_id}", params: { partial_result: { time_s: true } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if no time is given' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/api/trainer/#{mode.id}/inputs/#{input_id}", params: { partial_result: { success: true } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns not found for other users' do
      post "/api/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post_login(eve.name, eve.password)
      post "/api/trainer/#{mode.id}/inputs/#{input_id}", params: { partial_result: { time_s: 10 } }
      expect(response).to have_http_status(:not_found)
      input = Input.find_by(id: input_id)
      expect(input).not_to be(nil)
      expect(input&.result).to be(nil)
    end
  end
end
