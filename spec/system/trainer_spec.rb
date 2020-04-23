# frozen_string_literal: true

require 'rails_helper'
require 'system_test_helper'
require 'fixtures'

describe 'trainer', type: :system do
  include_context :user
  include_context :mode

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to train' do
    visit '/login'
    login(user)
    sleep(0.5)

    # TODO: Figure out how to identify the right button in the mode list.

    visit "/trainer/#{mode.id}"

    click_button 'Start'
    sleep(0.5)
    click_button 'Stop and Start'
    sleep(0.5)
    click_button 'Hint'
    sleep(0.5)
    click_button 'Stop and Pause'

    # Check that hints are 0 and 1.
    # TODO: Figure out a better way to figure out whether the right results exist.
    expect(page).to have_text('0')
    expect(page).to have_text('1')
  end
end
