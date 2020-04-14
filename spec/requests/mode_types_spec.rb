require 'rails_helper'
require 'fixtures'

RSpec.describe "ModeTypes", type: :request do
  include_context :user

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get "/mode_types", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expected_mode_types = ModeType::ALL.map(&:to_simple).map do |m|
        m[:key] = m[:key].to_s
        m[:learner_type] = m[:learner_type].to_s
        m[:show_input_modes] = m[:show_input_modes].map(&:to_s) if m[:show_input_modes]
        m.transform_keys!(&:to_s)
      end
      expect(parsed_body).to eq(expected_mode_types)
    end
  end

  describe 'GET #show' do
    let(:mode_type) { ModeType::ALL.sample }

    it 'returns http success' do
      get "/mode_types/#{mode_type.key}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expected_mode_type = mode_type.to_simple
      expected_mode_type[:key] = expected_mode_type[:key].to_s
      expected_mode_type[:learner_type] = expected_mode_type[:learner_type].to_s
      expected_mode_type[:show_input_modes] = expected_mode_type[:show_input_modes].map(&:to_s) if expected_mode_type[:show_input_modes]
      expected_mode_type.transform_keys!(&:to_s)
      expect(parsed_body).to eq(expected_mode_type)
    end

    it 'returns not found for unknown mode types' do
      get "/modes/non_existing"
      expect(response).to have_http_status(:not_found)
    end
  end
end
