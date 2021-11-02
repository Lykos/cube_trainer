# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'
require 'requests/requests_spec_helper'

RSpec.describe 'Modes', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with mode'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'GET #name_exists_for_user?' do
    it 'returns true if a user exists' do
      get '/mode_name_exists_for_user', params: { mode_name: mode.name }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it "returns false if a name doesn't exist" do
      get '/mode_name_exists_for_user', params: { mode_name: 'new_mode_name' }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(false)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      mode
      get '/modes', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_mode = parsed_body.any? { |p| Mode.new(p) == mode }
      expect(contains_mode).to be(true)
    end

    it 'returns nothing for another user' do
      mode
      post_login(eve.name, eve.password)
      get '/modes', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to be_empty
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/modes/#{mode.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(Mode.new(parsed_body)).to eq(mode)
    end

    it 'returns not found for unknown modes' do
      get '/modes/143432332'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/modes/#{mode.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/modes/#{mode.id}new"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get "/modes/#{mode.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post '/modes', params: {
        mode: {
          name: 'test_mode2',
          show_input_mode: :name,
          mode_type: :floating_2flips,
          goal_badness: 1,
          cube_size: 3
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(mode.id)
      expect(Mode.find(parsed_body['id']).name).to eq('test_mode2')
    end

    it 'returns bad request for invalid modes' do
      post '/modes', params: {
        mode: {
          name: 'test_mode2',
          show_input_mode: :lol,
          mode_type: :floating_2flips,
          goal_badness: 1,
          cube_size: 3
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/modes/#{mode.id}", params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:success)
      mode.reload
      expect(mode.goal_badness).to eq(2)
      expect(mode.cube_size).to eq(3)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/modes/#{mode.id}", params: { mode: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Mode.find(mode.id).goal_badness).to eq(1)
    end

    it 'returns not found for unknown modes' do
      put '/modes/143432332', params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      put "/modes/#{mode.id}", params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
      expect(Mode.find(mode.id).goal_badness).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/modes/#{mode.id}"
      expect(response).to have_http_status(:success)
      expect(Mode.exists?(mode.id)).to be(false)
    end

    it 'returns not found for unknown modes' do
      delete '/modes/143432332'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      delete "/modes/#{mode.id}"
      expect(response).to have_http_status(:not_found)
      expect(Mode.exists?(mode.id)).to be(true)
    end
  end
end
