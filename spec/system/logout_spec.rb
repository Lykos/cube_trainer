# frozen_string_literal: true

require 'rails_helper'

describe 'logout' do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to log out' do
    login(user)

    click_button 'Logout'
    expect(page).to have_text('Logged Out')
  end
end
