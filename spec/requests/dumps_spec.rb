# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dumps', type: :request do
  include_context 'with user abc'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with alg spreadsheet'
  include_context 'with edges'

  let(:case_set) do
    CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, uf)
  end

  let(:alg_set) do
    alg_set = alg_spreadsheet.alg_sets.create!(case_set: case_set, sheet_title: 'test sheet')
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ur, ul])]
      ),
      alg: "M2 U M U2 M' U M2"
    )
    alg_set
  end

  describe 'GET /api/dump' do
    it 'returns http success' do
      get '/api/dump', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_body.keys).to contain_exactly(:achievement_grants, :color_scheme, :created_at, :training_sessions, :name, :provider, :uid, :admin, :email, :id, :letter_scheme, :messages)
      expect(parsed_body[:name]).to eq(user.name)
    end

    it 'returns http success for a fully featured user' do
      # Create a training_session.
      post '/api/training_sessions', headers: user_headers, params: {
        training_session: {
          name: 'test_training_session2',
          show_input_mode: :name,
          training_session_type: :edge_commutators,
          buffer: 'Edge:UF',
          goal_badness: 1,
          cube_size: 3,
          alg_set_id: alg_set.id,
          stat_types: [:averages]
        }
      }
      
      training_session_id = JSON.parse(response.body)['id']
      # Get a this training session.
      get "/api/training_sessions/#{training_session_id}", headers: user_headers
      case_key = JSON.parse(response.body)['training_cases'].sample['case_key']
      # Create a new result for this input.
      post "/api/training_sessions/#{training_session_id}/results", headers: user_headers, params: { result: { case_key: case_key, time_s: 10 } }
      # Create a new letter scheme.
      post '/api/letter_scheme', headers: user_headers, params: {
        letter_scheme: {
          mappings: [{ part: { key: 'Edge:UB' }, letter: 'd' }]
        }
      }
      # Create a new color scheme.
      post '/api/color_scheme', headers: user_headers, params: {
        color_scheme: {
          color_u: :yellow,
          color_f: :green
        }
      }
      # Create an alg override.
      post "/api/training_sessions/#{training_session_id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'Edge(UF UB DF)', alg: "[U2, M']" } }
      
      # Now get the dump
      get '/api/dump', headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_body[:letter_scheme][:mappings]).to match([include(letter: 'd', part: { key: 'Edge:UB', name: 'UB' })])
      expect(parsed_body[:color_scheme][:color_f]).to eq('green')
      parsed_training_session = parsed_body[:training_sessions][0]
      expect(parsed_training_session[:buffer][:name]).to eq('UF')
      expect(parsed_training_session[:case_set]).to eq('edge 3-cycles for buffer UF')
      expect(parsed_training_session[:results][0][:time_s]).to eq(10.0)
      expect(parsed_training_session[:stats][0][:stat_type][:id]).to eq('averages')
      expect(parsed_training_session[:alg_set][:id]).to eq(alg_set.id)
      expect(parsed_training_session[:alg_set][:owner]).to eq('Testy Testikow')
      expect(parsed_training_session[:alg_overrides][0][:alg]).to eq("[U2, M']")
    end

    it 'returns not found when not logged in' do
      get '/api/dump', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
