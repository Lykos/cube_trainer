# frozen_string_literal: true

require 'rails_helper'

describe 'trainer', type: :system do
  include_context 'with user abc'
  include_context 'with training session'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to train' do
    login(user)
    sleep(0.5)

    # TODO: Figure out how to identify the right button in the mode list.

    visit "/training/#{mode.id}"

    click_button 'Start'
    sleep(0.5)
    click_button 'Stop and Start'
    sleep(0.5)
    click_button 'Stop and Pause'

    # TODO: Check hints
  end
end
