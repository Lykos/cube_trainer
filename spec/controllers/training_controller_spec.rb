# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainerController, type: :controller, focus: true do
  let(:user) { User.create!(name: 'abc', password: 'password', password_confirmation: 'password') }
  let(:mode) {
    user.modes.create!(
      name: 'test_mode',
      show_input_mode: name,
      mode_type: :floating_2flips,
      goal_badness: 1,
    )
  }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post "/trainer/#{mode.id}/inputs"
      expect(response).to have_http_status(:success)
      p response
    end
  end
end
