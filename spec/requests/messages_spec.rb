# frozen_string_literal: true

require 'rails_helper'
require 'requests/requests_spec_helper'

RSpec.describe 'Messages', type: :request do
  include_context :user
  include_context :eve
  include_context :user_message
  include_context :headers

  before(:each) do
    post_login(user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      user_message
      get "/users/#{user.id}/messages", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to be >= 1
      contains_message = parsed_body.any? { |p| Message.new(p) == user_message }
      expect(contains_message).to be(true)
    end

    it 'returns not found for another user' do
      user_message
      post_login(eve.name, eve.password)
      get "/users/#{user.id}/messages", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get "/users/#{user.id}/messages/#{user_message.id}", headers: headers
      expect(response).to have_http_status(:success)
      parsed_body = JSON.parse(response.body)
      expect(Message.new(parsed_body)).to eq(user_message)
    end

    it 'returns not found for unknown messages' do
      get "/users/#{user.id}/messages/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user' do
      post_login(eve.name, eve.password)
      get "/users/#{user.id}/messages/#{user_message.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get "/users/#{user.id}/messages/#{user_message.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    it 'returns http success' do
      put "/users/#{user.id}/messages/#{user_message.id}", params: { message: { read: true } }
      expect(response).to have_http_status(:success)
      user_message.reload
      expect(user_message.title).to eq('message_title')
      expect(user_message.read).to eq(true)
    end

    it 'returns not found for unknown messages' do
      put "/users/#{user.id}/messages/143432332", params: { message: { read: true } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      put "/users/#{user.id}/messages/#{user_message.id}", params: { message: { read: true } }
      expect(response).to have_http_status(:not_found)
      expect(Message.find(user_message.id).read).to eq(false)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns http success' do
      delete "/users/#{user.id}/messages/#{user_message.id}"
      expect(response).to have_http_status(:success)
      expect(Message.exists?(user_message.id)).to be(false)
    end

    it 'returns not found for unknown messages' do
      delete "/users/#{user.id}/messages/143432332"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for other users' do
      post_login(eve.name, eve.password)
      delete "/users/#{user.id}/messages/#{user_message.id}"
      expect(response).to have_http_status(:not_found)
      expect(Message.exists?(user_message.id)).to be(true)
    end
  end
end
