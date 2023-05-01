# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'TrainingSessions' do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with training session'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #name_exists_for_user?' do
    it 'returns true if a user exists' do
      get '/api/training_session_name_exists_for_user', params: { training_session_name: training_session.name }, headers: user_headers
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to be(true)
    end

    it "returns false if a name doesn't exist" do
      get '/api/training_session_name_exists_for_user', params: { training_session_name: 'new_training_session_name' }, headers: user_headers
      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to be(false)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      training_session
      get '/api/training_sessions', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body
      expect(parsed_body.length).to be(1)
      parsed_training_session = parsed_body.find { |p| p['id'] == training_session.id }.deep_symbolize_keys
      expect(parsed_training_session).to include(name: 'test_training_session')
    end

    it 'returns nothing for another user' do
      training_session
      get '/api/training_sessions', headers: eve_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body
      expect(parsed_body).to be_empty
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/training_sessions/#{training_session.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body.deep_symbolize_keys
      expect(parsed_body).to include(show_input_mode: 'name', generator_type: 'case', buffer: { key: 'Edge:UF', name: 'UF' }, goal_badness: 1.0, cube_size: 3, known: false)
    end

    it 'returns not found for unknown training_sessions' do
      get '/api/training_sessions/143432332', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/training_sessions/#{training_session.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/api/training_sessions/#{training_session.id}new", headers: user_headers
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post '/api/training_sessions', headers: user_headers, params: {
        training_session: {
          name: 'test_training_session2',
          show_input_mode: :name,
          training_session_type: :floating_2flips,
          goal_badness: 1,
          cube_size: 3
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = response.parsed_body
      expect(parsed_body['id']).not_to eq(training_session.id)
      expect(TrainingSession.find(parsed_body['id']).name).to eq('test_training_session2')
    end

    it 'returns bad request for invalid training_sessions' do
      post '/api/training_sessions', headers: user_headers, params: {
        training_session: {
          name: 'test_training_session2',
          show_input_mode: :lol,
          training_session_type: :floating_2flips,
          goal_badness: 1,
          cube_size: 3
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/api/training_sessions/#{training_session.id}", headers: user_headers, params: { training_session: { goal_badness: 2 } }
      expect(response).to have_http_status(:success)
      training_session.reload
      expect(training_session.goal_badness).to eq(2)
      expect(training_session.cube_size).to eq(3)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/api/training_sessions/#{training_session.id}", headers: user_headers, params: { training_session: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(TrainingSession.find(training_session.id).goal_badness).to eq(1)
    end

    it 'returns not found for unknown training_sessions' do
      put '/api/training_sessions/143432332', headers: user_headers, params: { training_session: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      put "/api/training_sessions/#{training_session.id}", headers: eve_headers, params: { training_session: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
      expect(TrainingSession.find(training_session.id).goal_badness).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/training_sessions/#{training_session.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      expect(TrainingSession.exists?(training_session.id)).to be(false)
    end

    it 'returns not found for unknown training_sessions' do
      delete '/api/training_sessions/143432332', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      delete "/api/training_sessions/#{training_session.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
      expect(TrainingSession.exists?(training_session.id)).to be(true)
    end
  end
end
