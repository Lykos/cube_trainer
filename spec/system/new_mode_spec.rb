# frozen_string_literal: true

require 'rails_helper'
require 'system_test_helper'
require 'fixtures'

describe 'modes', type: :system , focus: true do
  include_context :user

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new mode' do
    visit '/login'
    login(user)

    click_button 'Cube Trainer'
    click_button 'New'

    sleep(0.5)
    fill_in 'Name', with: 'system test mode'
    mat_select 'Corner Commutators', from: 'modeType'
    click_button 'Next'

    sleep(0.5)
    fill_in 'Cube Size', with: '3'
    mat_select 'ULB', from: 'buffer'
    click_button 'Next'

    sleep(0.5)
    mat_select 'name', from: 'showInputMode'
    fill_in 'Goal Time per Element', with: '2.0'
    click_button 'Next'

    sleep(0.5)
    # Not adding any stats because drag and drop is buggy with Selenium.
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Mode system test mode Created!')
  end
end
