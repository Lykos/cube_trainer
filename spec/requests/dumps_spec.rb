# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dumps', type: :request do
  include_context 'with user abc'
  include_context 'with headers'
  include_context 'with user auth headers'

  describe 'GET /api/dump' do
    it 'returns http success' do
      get '/api/dump', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to contain_exactly('achievement_grants', 'color_scheme', 'created_at', 'modes', 'name', 'provider', 'uid', 'admin', 'email', 'id', 'letter_scheme', 'messages')
      expect(parsed_body['name']).to eq(user.name)
    end

    it 'returns http success for a fully featured user' do
      # Create a mode.
      post '/api/modes', headers: user_headers, params: {
        mode: {
          name: 'test_mode2',
          show_input_mode: :name,
          mode_type: { key: :floating_2flips },
          goal_badness: 1,
          cube_size: 3,
          stat_types: [:averages]
        }
      }
      mode_id = JSON.parse(response.body)['id']
      # Get a new input.
      post "/api/trainer/#{mode_id}/inputs", headers: user_headers
      input_id = JSON.parse(response.body)['id']
      # Create a new result for this input.
      post "/api/trainer/#{mode_id}/inputs/#{input_id}", headers: user_headers, params: { partial_result: { time_s: 10 } }
      # Create a new letter scheme.
      post '/api/letter_scheme', headers: user_headers, params: {
        letter_scheme: {
          mappings: [{ part: { key: 'Edge:UB' }, letter: 'd' }]
        }
      }
      # Create a new color scheme.
      post '/api/color_scheme', headers: user_headers, params: {
        color_scheme: {
          u: :yellow,
          f: :green,
          r: :orange,
          l: :red,
          b: :blue,
          d: :white
        }
      }

      # Now get the dump
      get '/api/dump', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['letter_scheme']['mappings']).to eq_modulo_symbol_vs_string([{ letter: 'd', part: { key: 'Edge:UB', name: 'UB' } }])
      expect(parsed_body['color_scheme']['f']).to eq('green')
      expect(parsed_body['modes'][0]['results'][0]['time_s']).to eq(10.0)
    end

    it 'returns not found when not logged in' do
      get '/api/dump', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
