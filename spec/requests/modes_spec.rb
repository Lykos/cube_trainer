require 'rails_helper'

RSpec.describe "Modes", type: :request, focus: true do
  let(:user) do
    User.create!(
      name: 'abc',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  let(:eve) do
    User.create!(
      name: 'eve',
      password: 'password',
      password_confirmation: 'password'
    )
  end
  
  let(:mode) do
    user.modes.create!(
      name: 'test_mode',
      show_input_mode: :name,
      mode_type: :floating_2flips,
      goal_badness: 1,
      cube_size: 3
    )
  end

  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #types' do
    it 'returns http success' do
      get "/mode_types", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(Mode::MODE_TYPES)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      get "/modes", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq([mode.to_json])
    end

    it 'returns nothing for another user' do
      post "/login", params: { username: eve.name, password: eve.password }
      get "/modes", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to be_empty
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/modes", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(mode.to_json)
    end

    it 'returns not found for unknown modes' do
      get "/modes/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post "/login", params: { username: eve.name, password: eve.password }
      get "/modes", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/modes/#{mode.id}new"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get "/modes/#{mode.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/modes", params: {
             mode: {
               name: 'test_mode2',
               show_input_mode: :name,
               mode_type: :floating_2flips,
               goal_badness: 1,
               cube_size: 3
             }
           }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(mode.id)
      expect(Mode.find(parsed_body['id']).name).to eq('test_mode2')
    end

    it 'returns unprocessable entity for invalid modes' do
      post "/modes", params: {
             mode: {
               name: 'test_mode2',
               show_input_mode: :lol,
               mode_type: :floating_2flips,
               goal_badness: 1,
               cube_size: 3
             }
           }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/modes/#{mode.id}", params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:success)
      mode.reload
      expect(mode.goal_badness).to eq(2)
      expect(mode.cube_size).to eq(3)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/modes/#{mode.id}", params: { mode: { name: nil } }
      expect(response).to have_http_status(:not_found)
      expect(Mode.find(mode.id).goal_badness).to eq(1)
    end

    it 'returns not found for unknown modes' do
      put "/modes/143432332", params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/login", params: { username: eve.name, password: eve.password }
      put "/modes/#{mode.id}", params: { mode: { goal_badness: 2 } }
      expect(response).to have_http_status(:not_found)
      expect(Mode.find(mode.id).goal_badness).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/modes/#{mode.id}"
      expect(response).to have_http_status(:success)
      expect(Mode.exists?(mode.id)).to be(false)
    end

    it 'returns not found for unknown modes' do
      delete "/modes/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/login", params: { username: eve.name, password: eve.password }
      delete "/modes/#{mode.id}"
      expect(response).to have_http_status(:not_found)
      expect(Mode.exists?(mode.id)).to be(true)
    end
  end
end
