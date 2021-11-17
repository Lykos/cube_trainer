# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'

describe 'logout', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to log out' do
    login(user)
 
    visit '/modes'
    click_link 'Logout'
    expect(page).to have_text('Logged Out')
  end
end
