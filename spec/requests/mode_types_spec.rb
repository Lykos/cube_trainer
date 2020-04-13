require 'rails_helper'
require 'fixtures'

RSpec.describe "ModeTypes", type: :request do
  include_context :user

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #types' do
    it 'returns http success' do
      get "/mode_types", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expected_modes = ModeType::ALL.map(&:to_simple).map do |m|
        m[:name] = m[:name].to_s
        m[:show_input_modes] = m[:show_input_modes].map(&:to_s) if m[:show_input_modes]
        m.transform_keys!(&:to_s)
      end
      expect(parsed_body).to eq(expected_modes)
    end
  end
end
