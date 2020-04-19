require 'rails_helper'
require 'fixtures'
require 'requests/requests_helper'
require 'matchers'

RSpec.describe "ModeTypes", type: :request do
  include_context :user
  include_context :headers

  before(:each) do
    login(user.name, user.password)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get "/mode_types", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(ModeType::ALL.map(&:to_simple))
    end
  end

  describe 'GET #show' do
    let(:mode_type) { ModeType::ALL.sample }

    it 'returns http success' do
      get "/mode_types/#{mode_type.key}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq_modulo_symbol_vs_string(mode_type.to_simple)
    end

    it 'returns not found for unknown mode types' do
      get "/modes/non_existing"
      expect(response).to have_http_status(:not_found)
    end
  end
end
