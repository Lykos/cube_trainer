require 'rails_helper'
require 'fixtures'

RSpec.describe "Trainer", type: :request do
  include_context :user
  include_context :eve
  include_context :mode

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get "/trainer/#{mode.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.keys).to eq(['id', 'inputRepresentation'])
      expect(Input.find(parsed_body['id'])).not_to be(nil)
    end

    it 'returns not found for unknown modes' do
      post "/trainer/143432332/inputs"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/login", params: { username: eve.name, password: eve.password }
      post "/trainer/#{mode.id}/inputs", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      delete "/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:success)
      expect(Input.exists?(id: input_id)).to be(false)
    end

    it 'returns not found for unknown modes' do
      delete "/trainer/143432332/inputs/1"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for unknown inputs' do
      delete "/trainer/1/inputs/1243943"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/login", params: { username: eve.name, password: eve.password }
      delete "/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:not_found)
      expect(Input.exists?(id: input_id)).to be(true)
    end
  end

  describe 'POST #stop' do
    it 'returns http success' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/trainer/#{mode.id}/inputs/#{input_id}", params: { time_s: 10 }
      expect(response).to have_http_status(:success)
      expect(Input.find(input_id).result.time).to eq(10.seconds)
    end

    it 'returns not found for unknown modes' do
      post "/trainer/143432332/inputs/1"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for unknown inputs' do
      post "/trainer/1/inputs/1243943"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unprocessable entity if no time is given' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/trainer/#{mode.id}/inputs/#{input_id}"
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns not found for other users' do
      post "/trainer/#{mode.id}/inputs", headers: headers
      input_id = JSON.parse(response.body)['id']
      post "/login", params: { username: eve.name, password: eve.password }
      post "/trainer/#{mode.id}/inputs/#{input_id}", params: { time_s: 10 }
      expect(response).to have_http_status(:not_found)
      input = Input.find_by(id: input_id)
      expect(input).not_to be(nil)
      expect(input&.result).to be(nil)
    end
  end
end
