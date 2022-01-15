# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'TrainingSessionTypes', type: :request do
  include_context 'with user abc'
  include_context 'with headers'

  describe 'GET #index' do
    it 'returns http success' do
      get '/api/training_session_types', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).map(&:deep_symbolize_keys)
      expect(parsed_body.length).to eq(TrainingSessionType.all.length)
      expect(parsed_body).to include(include( id: 'xcenter_commutators', name: 'X-Center Commutators', has_goal_badness: true, has_bounded_inputs: true, has_memo_time: nil ))
    end
  end

  describe 'GET #show' do
    let(:training_session_type) { TrainingSessionType.find_by!(id: :edge_commutators) }

    it 'returns http success' do
      get "/api/training_session_types/#{training_session_type.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body).deep_symbolize_keys
      expect(parsed_body).to include(id: 'edge_commutators', name: 'Edge Commutators', has_goal_badness: true, has_bounded_inputs: true, has_memo_time: nil )
    end

    it 'returns not found for unknown training_session types' do
      get '/api/training_session_types/non_existing', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
