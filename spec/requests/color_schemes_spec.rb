# frozen_string_literal: true

require 'rails_helper'
require 'fixtures'
require 'requests/requests_spec_helper'

RSpec.describe 'ColorSchemes', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with color scheme'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'GET #name_exists_for_user?' do
    it 'returns true if a user exists' do
      get '/api/color_scheme_name_exists_for_user', params: { color_scheme_name: color_scheme.name }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it "returns false if a name doesn't exist" do
      get '/api/color_scheme_name_exists_for_user', params: { color_scheme_name: 'new_color_scheme_name' }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(false)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      color_scheme
      get '/api/color_schemes', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_color_scheme = parsed_body.any? { |p| ColorScheme.new(p) == color_scheme }
      expect(contains_color_scheme).to be(true)
    end

    it 'returns nothing for another user' do
      color_scheme
      post_login(eve.name, eve.password)
      get '/api/color_schemes', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to be_empty
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/color_schemes/#{color_scheme.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(ColorScheme.new(parsed_body)).to eq(color_scheme)
    end

    it 'returns not found for unknown color_schemes' do
      get '/api/color_schemes/143432332', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/api/color_schemes/#{color_scheme.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/api/color_schemes/#{color_scheme.id}new", headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post '/api/color_schemes', headers: headers, params: {
        color_scheme: {
          U: :yellow,
          F: :green,
          R: :orange,
          L: :red,
          B: :blue,
          D: :white,
          name: 'idk',
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(color_scheme.id)
      expect(ColorScheme.find(parsed_body['id']).name).to eq('idk')
    end

    it 'returns bad request for invalid color_schemes' do
      post '/api/color_schemes', params: {
        color_scheme: {
          U: :red
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/api/color_schemes/#{color_scheme.id}", headers: headers, params: { color_scheme: { name: 'new name' } }
      expect(response).to have_http_status(:success)
      color_scheme.reload
      expect(color_scheme.name).to eq('new name')
      expect(color_scheme.U).to eq(:yellow)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/api/color_schemes/#{color_scheme.id}", headers: headers, params: { color_scheme: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(ColorScheme.find(color_scheme.id).name).to eq('test_color_scheme')
    end

    it 'returns not found for unknown color_schemes' do
      put '/api/color_schemes/143432332', headers: headers, params: { color_scheme: { name: 'new name' } }
      expect(response).to have_http_status(:not_found)
      expect(ColorScheme.find(color_scheme.id).name).to eq('test_color_scheme')
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      put "/api/color_schemes/#{color_scheme.id}", headers: headers, params: { color_scheme: { name: 'new name' } }
      expect(response).to have_http_status(:not_found)
      expect(ColorScheme.find(color_scheme.id).name).to eq('test_color_scheme')
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/color_schemes/#{color_scheme.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(ColorScheme.exists?(color_scheme.id)).to be(false)
    end

    it 'returns not found for unknown color_schemes' do
      delete '/api/color_schemes/143432332', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      delete "/api/color_schemes/#{color_scheme.id}", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(ColorScheme.exists?(color_scheme.id)).to be(true)
    end
  end
end
