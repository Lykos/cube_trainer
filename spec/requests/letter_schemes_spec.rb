# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'LetterSchemes', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with letter scheme'
  include_context 'with headers'

  before do
    post_login(user)
  end

  describe 'GET #show' do
    it 'returns http success' do
      letter_scheme
      get '/api/letter_scheme', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(letter_scheme.to_simple)
    end

    it 'returns not found for user with no letter scheme' do
      post_login(eve)
      get '/api/letter_scheme', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post_login(eve)
      post '/api/letter_scheme', headers: headers, params: {
        letter_scheme: {
          mappings: [{ part: { key: 'Edge:UB' }, letter: 'd' }]
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(letter_scheme.id)
      expect(LetterScheme.find(parsed_body['id']).letter(TwistyPuzzles::Edge.for_face_symbols(%i[U B]))).to eq('d')
    end

    xit 'returns bad request if the user already has a letter scheme' do
      letter_scheme
      post '/api/letter_scheme', params: {
        letter_scheme: {
          mappings: [{ part: { key: 'Edge:UB' }, letter: 'a' }]
        }
      }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request for invalid letter_schemes' do
      post_login(eve)
      post '/api/letter_scheme', params: {
        letter_scheme: {
          mappings: [{ part: { key: 'Edge:UB' }, letter: 'long' }]
        }
      }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      letter_scheme
      put '/api/letter_scheme', headers: headers, params: { letter_scheme: { mappings: [{ part: { key: 'Edge:UB' }, letter: 'd' }] } }
      expect(response).to have_http_status(:success)
      letter_scheme.reload
      expect(letter_scheme.letter(TwistyPuzzles::Edge.for_face_symbols(%i[U F]))).to eq('a')
      expect(letter_scheme.letter(TwistyPuzzles::Edge.for_face_symbols(%i[U B]))).to eq('d')
    end

    it 'returns unprocessable entity for invalid updates' do
      letter_scheme
      put '/api/letter_scheme', headers: headers, params: { letter_scheme: { mappings: [{ part: { key: 'Edge:UB' }, letter: 'long' }] } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(LetterScheme.find(letter_scheme.id).letter(TwistyPuzzles::Edge.for_face_symbols(%i[U F]))).to eq('a')
    end

    it 'returns not found for user with no letter scheme' do
      post_login(eve)
      put '/api/letter_scheme', headers: headers, params: { letter_scheme: { mappings: [{ part: { key: 'Edge:UB' }, letter: 'd' }] } }
      expect(response).to have_http_status(:not_found)
      expect(LetterScheme.find(letter_scheme.id).letter(TwistyPuzzles::Edge.for_face_symbols(%i[U F]))).to eq('a')
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      letter_scheme
      delete '/api/letter_scheme', headers: headers
      expect(response).to have_http_status(:success)
      expect(LetterScheme.exists?(letter_scheme.id)).to be(false)
    end

    it 'returns not found for user with no letter scheme' do
      post_login(eve)
      delete '/api/letter_scheme', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
