# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'
require 'fixtures'

RSpec.describe 'Users', type: :request do
  include_context 'with user abc'
  include_context 'with user eve'
  include_context 'with user admin'
  include_context 'with headers'

  describe 'GET #username_or_email_exists?' do
    it 'returns true if a user exists' do
      get '/username_or_email_exists', params: { username_or_email: user.name }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it 'returns true if an email exists' do
      get '/username_or_email_exists', params: { username_or_email: user.email }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(true)
    end

    it "returns false if an username/email doesn't exist" do
      get '/username_or_email_exists', params: { username_or_email: 'grmlefex' }, headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(false)
    end
  end

  describe 'GET #index' do
    it 'returns http success for admin' do
      admin
      eve
      user
      post_login(admin.name, admin.password)
      get '/users', headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      users = parsed_body.map { |u| User.new(u) }
      expect(users).to include(admin)
      expect(users).to include(eve)
      expect(users).to include(user)
    end

    it 'returns unauthorized for non-admins' do
      post_login(user)
      get '/users', headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #show' do
    before { post_login(user) }

    it 'returns http success' do
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns http success for admin' do
      post_login(admin.name, admin.password)
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(User.new(parsed_body)).to eq(user)
    end

    it 'returns not found for unknown users' do
      get '/users/143432332', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post '/users', headers: headers, params: {
        user: {
          name: 'new_user',
          email: 'new_user@example.org',
          password: 'abc',
          password_confirmation: 'abc'
        }
      }
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).not_to eq(user.id)
      expect(User.find(parsed_body['id']).name).to eq('new_user')
      expect(User.find(parsed_body['id']).messages.first.title).to eq('Welcome')
    end

    it 'returns http success for admin' do
      post_login(admin.name, admin.password)
      post '/users', headers: headers, params: {
        user: {
          name: 'new_user',
          email: 'new_user@example.org',
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

    it 'returns bad request for users with existing name' do
      post '/users', headers: headers, params: {
        user: {
          name: user.name,
          email: 'new_user@example.org',
          password: 'abc',
          password_confirmation: 'abc'
        }
      }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request for users with existing email' do
      post '/users', headers: headers, params: {
        user: {
          name: 'new_user',
          email: user.email,
          password: 'abc',
          password_confirmation: 'abc'
        }
      }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad request for invalid users' do
      post '/users', headers: headers, params: {
        user: {
          name: 'new_user',
          email: 'new_user@example.org',
          password: 'abc',
          password_confirmation: 'cde'
        }
      }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns unauthorized if setting admin while not admin' do
      post '/users', headers: headers, params: {
        user: {
          name: 'new_user',
          email: 'new_user@example.org',
          password: 'abc',
          password_confirmation: 'abc',
          admin: true
        }
      }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT #update' do
    before do
      post_login(user)
    end

    it 'returns http success' do
      post_login(admin.name, admin.password)
      put "/users/#{admin.id}", headers: headers, params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:success)
      admin.reload
      expect(admin.name).to eq('dodo')
      expect(admin.admin).to eq(true)
    end

    it 'returns unprocessable entity for invalid updates' do
      put "/users/#{user.id}", headers: headers, params: { user: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.find(user.id).name).to eq('abc')
    end

    it 'returns unauthorized if setting admin' do
      put "/users/#{user.id}", headers: headers, params: { user: { admin: true } }
      expect(response).to have_http_status(:unauthorized)
      expect(User.find(user.id).admin).to eq(false)
    end

    it 'returns success for admin' do
      post_login(admin.name, admin.password)
      put "/users/#{user.id}", headers: headers, params: { user: { admin: true } }
      expect(response).to have_http_status(:success)
      expect(User.find(user.id).admin).to eq(true)
    end

    it 'returns not found for unknown users' do
      put '/users/143432332', headers: headers, params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      put "/users/#{user.id}", headers: headers, params: { user: { name: 'dodo' } }
      expect(response).to have_http_status(:not_found)
      expect(User.find(user.id).name).to eq('abc')
    end
  end

  describe 'DELETE #destroy' do
    before do
      post_login(user)
    end

    it 'returns http success' do
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:success)
      expect(User.exists?(user.id)).to be(false)
    end

    it 'returns not found for unknown users' do
      delete '/users/143432332'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:not_found)
      expect(User.exists?(user.id)).to be(true)
    end
  end
end
