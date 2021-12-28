# frozen_string_literal: true

require 'rails_helper'

describe 'new mode', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new commutator mode' do
    login(user)

    visit '/modes'
    click_link 'Cube Trainer'
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
    click_button 'Next'

    sleep(0.5)
    mat_select 'name', from: 'showInputMode'
    fill_in 'Goal Time per Element', with: '2.0'
    click_button 'Next'

    sleep(0.5)
    # Not adding any stats because drag and drop is buggy with Selenium.
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Mode system test mode created.')
  end

  it 'allows to create a new memo rush mode' do
    login(user)

    visit '/modes'
    click_link 'Cube Trainer'
    click_button 'New'

    sleep(0.5)
    fill_in 'Name', with: 'system test mode'
    mat_select 'Memo Rush', from: 'modeType'
    click_button 'Next'

    sleep(0.5)
    click_button 'Next'

    sleep(0.5)
    click_button 'Next'

    sleep(0.5)
    fill_in 'Memo Time', with: '20.0'
    click_button 'Next'

    sleep(0.5)
    # Not adding any stats because drag and drop is buggy with Selenium.
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Mode system test mode created.')
  end
end
