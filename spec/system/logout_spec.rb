# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'
require 'fixtures'

describe 'logout', type: :system do
  include_context :user

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to train' do
    visit '/login'
    login(user)

    click_button 'Logout'
    expect(page).to have_text('Login')
  end
end
