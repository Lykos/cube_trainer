require 'rails_helper'
require 'fixtures'

RSpec.describe "Users", type: :request do
  include_context :user
  include_context :eve
  include_context :admin

  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before(:each) do
    post "/login", params: { username: user.name, password: user.password }
  end

  describe 'GET #index' do
    it 'returns http success for admin' do
      admin
      eve
      user
      post "/login", params: { username: admin.name, password: admin.password }
      get "/users", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      users = parsed_body.map { |u| User.new(u) }
      expect(users).to include(admin)
      expect(users).to include(eve)
      expect(users).to include(user)
    end

    it 'returns unauthorized for non-admins' do
      get "/users", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns http success for admin' do
      post "/login", params: { username: admin.name, password: admin.password }
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns not found for unknown users' do
      get "/users/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post "/login", params: { username: eve.name, password: eve.password }
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get "/users/#{user.id}new"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get "/users/#{user.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/users", params: {
             user: {
               name: 'new_user',
               password: 'abc',
               password_confirmation: 'abc'
             }
           }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(user.id)
      expect(User.find(parsed_body['id']).name).to eq('new_user')
    end

    it 'returns http success for admin' do
      post "/login", params: { username: admin.name, password: admin.password }
      post "/users", params: {
             user: {
               name: 'new_user',
               password: 'abc',
               password_confirmation: 'abc',
               admin: true
             }
           }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(user.id)
      expect(User.find(parsed_body['id']).name).to eq('new_user')
      expect(User.find(parsed_body['id']).admin).to eq(true)
    end

    it 'returns unprocessable entity for invalid users' do
      post "/users", params: {
             user: {
               name: 'new_user',
               password: 'abc',
               password_confirmation: 'cde'
             }
           }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "doesn't set admin if not admin" do
      post "/users", params: {
             user: {
               name: 'new_user',
               password: 'abc',
               password_confirmation: 'abc',
               admin: true
             }
           }
      expect(response).to have_http_status(:created)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(user.id)
      expect(User.find(parsed_body['id']).admin).to eq(false)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      post "/login", params: { username: admin.name, password: admin.password }
      put "/users/#{admin.id}", params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:success)
      admin.reload
      expect(admin.name).to eq(dodo)
      expect(admin.admin).to eq(true)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/users/#{user.id}", params: { user: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.find(user.id).name).to eq('users_abc')
    end

    it 'returns unprocessable entity if setting admin' do
      put "/users/#{user.id}", params: { user: { admin: true } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.find(user.id).admin).to eq(false)
    end

    it 'returns success for admin' do
      post "/login", params: { username: admin.name, password: admin.password }
      put "/users/#{user.id}", params: { user: { admin: true } }
      expect(response).to have_http_status(:success)
      expect(User.find(user.id).admin).to eq(true)
    end

    it 'returns not found for unknown users' do
      put "/users/143432332", params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/login", params: { username: eve.name, password: eve.password }
      put "/users/#{user.id}", params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:not_found)
      expect(User.find(user.id).name).to eq('users_abc')
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:success)
      expect(User.exists?(user.id)).to be(false)
    end

    it 'returns not found for unknown users' do
      delete "/users/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post "/login", params: { username: eve.name, password: eve.password }
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:not_found)
      expect(User.exists?(user.id)).to be(true)
    end
  end
end
