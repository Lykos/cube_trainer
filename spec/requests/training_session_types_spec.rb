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
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(TrainingSessionType.all.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    let(:training_session_type) { TrainingSessionType.all.sample }

    it 'returns http success' do
      get "/api/training_session_types/#{training_session_type.key}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(training_session_type.to_simple)
    end

    it 'returns not found for unknown training_session types' do
      get '/api/training_session_types/non_existing', headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
