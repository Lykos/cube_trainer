# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AlgOverrides', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with mode'
  include_context 'with headers'
  include_context 'with user auth headers'
  include_context 'with eve auth headers'
  include_context 'with alg override'

  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }

  describe 'GET #index' do
    it 'returns http success' do
      AlgOverride.delete_all
      alg_override
      get "/api/modes/#{mode.id}/alg_overrides", params: { offset: 0, limit: 100 }, headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eq(1)
      parsed_item = parsed_body[0]
      expect(parsed_item['id']).to eq(alg_override.id)
      expect(parsed_item['alg']).to eq(alg_override.alg)
    end

    it 'returns not found for another user' do
      get "/api/modes/#{mode.id}/alg_overrides", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(alg_override.id)
      expect(parsed_body['alg']).to eq(alg_override.alg)
    end

    it 'returns not found for unknown alg_overrides' do
      get "/api/modes/#{mode.id}/alg_overrides/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      get "/api/modes/#{mode.id}/alg_overrides", headers: eve_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers
      expect(response).to have_http_status(:success)
      expect(AlgOverride.exists?(alg_override.id)).to be(false)
    end

    it 'returns not found for unknown alg_overrides' do
      delete "/api/modes/#{mode.id}/alg_overrides/143432332", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      delete "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: eve_headers
      expect(response).to have_http_status(:not_found)
      expect(AlgOverride.exists?(alg_override.id)).to be(true)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      alg_override_id = parsed_body['id']
      expect(parsed_body['case_key']).to eq('PartCycle:Edge(UF UB DF)')
      expect(parsed_body['alg']).to eq("[U2, M']")
      expect(AlgOverride.find(alg_override_id).alg).to eq("[U2, M']")
    end

    it 'returns not found for unknown modes' do
      post '/api/modes/143432332/alg_overrides', headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request if an unparseable alg is given' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "[U2, M',,]" } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if an invalid alg is given' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: '[U2, M2]' } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if no alg is given' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)' } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if no case is given' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { alg: "[U2, M']" } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if a case for a different buffer is given' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UB UF DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request if a case for a different part type' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:TCenter(UB UF DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns not found for other users' do
      post "/api/modes/#{mode.id}/alg_overrides", headers: eve_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT/PATCH #update' do
    it 'returns http success' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "U2 M' U2 M" } }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      alg_override_id = parsed_body['id']
      expect(parsed_body['id']).to eq(alg_override.id)
      expect(parsed_body['alg']).to eq("U2 M' U2 M")
      expect(AlgOverride.find(alg_override_id).alg).to eq("U2 M' U2 M")
    end

    it 'returns not found for unknown modes' do
      put "/api/modes/143432332/alg_overrides/#{alg_override.id}", headers: user_headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request if an unparseable alg is given' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "[U2, M',,]" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request if an invalid alg is given' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: '[U2, M2]' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request if no alg is given' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request if no case is given' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { alg: "[U2, M']" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request if a case for a different buffer is given' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UB UF DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad request if a case for a different part type' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: user_headers, params: { alg_override: { case_key: 'PartCycle:TCenter(UB UF DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns not found for other users' do
      put "/api/modes/#{mode.id}/alg_overrides/#{alg_override.id}", headers: eve_headers, params: { alg_override: { case_key: 'PartCycle:Edge(UF UB DF)', alg: "[U2, M']" } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
