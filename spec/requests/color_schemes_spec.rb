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

  describe 'GET #show' do
    it 'returns http success' do
      color_scheme
      get '/api/color_scheme', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(ColorScheme.new(parsed_body)).to eq(color_scheme)
    end

    it 'returns not found for user with no color scheme' do
      post_login(eve)
      get '/api/color_scheme', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post_login(eve)
      post '/api/color_scheme', headers: headers, params: {
        color_scheme: {
          u: :yellow,
          f: :green,
          r: :orange,
          l: :red,
          b: :blue,
          d: :white
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(color_scheme.id)
      expect(ColorScheme.find(parsed_body['id']).u).to eq(:yellow)
    end

    it 'returns bad request for invalid color_schemes' do
      post_login(eve)
      post '/api/color_scheme', params: {
        color_scheme: {
          u: :red
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      color_scheme
      put '/api/color_scheme', headers: headers, params: { color_scheme: { d: 'black' } }
      expect(response).to have_http_status(:success)
      color_scheme.reload
      expect(color_scheme.d).to eq(:black)
      expect(color_scheme.u).to eq(:yellow)
    end

    it 'returns unprocessable entity for invalid updates' do
      color_scheme
      put '/api/color_scheme', headers: headers, params: { color_scheme: { u: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(ColorScheme.find(color_scheme.id).u).to eq(:yellow)
    end

    it 'returns not found for user with no color scheme' do
      post_login(eve)
      put '/api/color_scheme', headers: headers, params: { color_scheme: { d: 'black' } }
      expect(response).to have_http_status(:not_found)
      expect(ColorScheme.find(color_scheme.id).u).to eq(:yellow)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      color_scheme
      delete '/api/color_scheme', headers: headers
      expect(response).to have_http_status(:success)
      expect(ColorScheme.exists?(color_scheme.id)).to be(false)
    end

    it 'returns not found for user with no color scheme' do
      post_login(eve)
      delete '/api/color_scheme', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
