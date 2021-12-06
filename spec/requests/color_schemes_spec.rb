# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'ColorSchemes', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with color scheme'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'

  describe 'GET #show' do
    it 'returns http success' do
      color_scheme
      get '/api/color_scheme', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(ColorScheme.new(parsed_body)).to eq(color_scheme)
    end

    it 'returns not found for user with no color scheme' do
      get '/api/color_scheme', headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post '/api/color_scheme', headers: eve_headers, params: {
        color_scheme: {
          color_u: :yellow,
          color_f: :green
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(color_scheme.id)
      expect(ColorScheme.find(parsed_body['id']).color_u).to eq(:yellow)
    end

    it 'returns unprocessable entity if the user already has a color scheme' do
      color_scheme
      post '/api/color_scheme', headers: user_headers, params: {
        color_scheme: {
          color_u: :yellow,
          color_f: :green
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request for invalid color_schemes' do
      post '/api/color_scheme', headers: eve_headers, params: {
        color_scheme: {
          color_u: :red
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      color_scheme
      put '/api/color_scheme', headers: user_headers, params: { color_scheme: { color_f: 'blue' } }
      expect(response).to have_http_status(:success)
      color_scheme.reload
      expect(color_scheme.color_f).to eq(:blue)
      expect(color_scheme.color_u).to eq(:yellow)
    end

    it 'returns unprocessable entity for invalid updates' do
      color_scheme
      put '/api/color_scheme', headers: user_headers, params: { color_scheme: { color_u: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(ColorScheme.find(color_scheme.id).color_u).to eq(:yellow)
    end

    it 'returns not found for user with no color scheme' do
      put '/api/color_scheme', headers: eve_headers, params: { color_scheme: { color_f: 'blue' } }
      expect(response).to have_http_status(:not_found)
      expect(ColorScheme.find(color_scheme.id).color_u).to eq(:yellow)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      color_scheme
      delete '/api/color_scheme', headers: user_headers
      expect(response).to have_http_status(:success)
      expect(ColorScheme.exists?(color_scheme.id)).to be(false)
    end

    it 'returns not found for user with no color scheme' do
      delete '/api/color_scheme', headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
