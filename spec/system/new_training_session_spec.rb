# frozen_string_literal: true

require 'rails_helper'

describe 'new training session', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new commutator training session' do
    login(user)

    visit '/training-sessions'
    click_link 'Cube Trainer'
    click_button 'New'

    sleep(0.5)
    fill_in 'Name', with: 'system test training session'
    mat_select 'Corner Commutators', from: 'trainingSessionType'
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
    expect(page).to have_text('Session system test training session created.')
  end

  it 'allows to create a new memo rush training session' do
    login(user)

    visit '/training-sessions'
    click_link 'Cube Trainer'
    click_button 'New'

    sleep(0.5)
    fill_in 'Name', with: 'system test training session'
    mat_select 'Memo Rush', from: 'trainingSessionType'
    click_button 'Next'

    sleep(0.5)
    fill_in 'Cube Size', with: '3'
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
    expect(page).to have_text('Session system test training session created.')
  end
end
