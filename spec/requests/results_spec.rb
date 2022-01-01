# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Results', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with result'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #index' do
    it 'returns http success' do
      Result.delete_all
      result
      get "/api/training_sessions/#{training_session.id}/results", params: { offset: 0, limit: 100 }, headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(result.id)
      expect(parsed_item['case_name']).to eq('DF UB')
      expect(parsed_item['time_s']).to eq(10)
      expect(parsed_item['failed_attempts']).to eq(0)
      expect(parsed_item['success']).to eq(true)
      expect(parsed_item['num_hints']).to eq(0)
    end

    it 'returns not found for another user' do
      get "/api/training_sessions/#{training_session.id}/results", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(result.id)
      expect(parsed_body['case_name']).to eq('DF UB')
      expect(parsed_body['time_s']).to eq(10)
      expect(parsed_body['failed_attempts']).to eq(0)
      expect(parsed_body['success']).to eq(true)
      expect(parsed_body['num_hints']).to eq(0)
    end

    it 'returns not found for unknown results' do
      get "/api/training_sessions/#{training_session.id}/results/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/training_sessions/#{training_session.id}/results", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      expect(Result.exists?(result.id)).to be(false)
    end

    it 'returns not found for unknown results' do
      delete "/api/training_sessions/#{training_session.id}/results/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      delete "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
      expect(Result.exists?(result.id)).to be(true)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/api/training_sessions/#{training_session.id}/results", headers: user_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: 10 } }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      result_id = parsed_body['id']
      expect(parsed_body['time_s']).to eq(10)
      expect(Result.find(result_id).time).to eq(10.seconds)
    end

    it 'returns not found for unknown training_sessions' do
      post '/api/training_sessions/143432332/results', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request if no numeric time is given' do
      post "/api/training_sessions/#{training_session.id}/results", headers: user_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: true } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if no time is given' do
      post "/api/training_sessions/#{training_session.id}/results", headers: user_headers, params: { result: { case_key: 'Edge(UF DF UB)', success: true } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns not found for other users' do
      post "/api/training_sessions/#{training_session.id}/results", headers: eve_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: 10 } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT/PATCH #update' do
    include_context 'with result'

    it 'returns http success' do
      put "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: user_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: 10 } }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      result_id = parsed_body['id']
      expect(parsed_body['time_s']).to eq(10)
      expect(Result.find(result_id).time).to eq(10.seconds)
    end

    it 'returns not found for unknown training_sessions' do
      put "/api/training_sessions/143432332/results/#{result.id}", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request if no numeric time is given' do
      put "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: user_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: true } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns not found for other users' do
      put "/api/training_sessions/#{training_session.id}/results/#{result.id}", headers: eve_headers, params: { result: { case_key: 'Edge(UF DF UB)', time_s: 10 } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
