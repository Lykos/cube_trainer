# frozen_string_literal: true

require 'rails_helper'

xdescribe 'trainer', type: :system do
  include_context 'with user abc'
  include_context 'with training session'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to train' do
    login(user)

    # TODO: Figure out how to identify the right button in the training_session list.

    visit "/training-sessions/#{training_session.id}"

    click_button 'Start'
    click_button 'Stop and Start'
    click_button 'Stop and Pause'

    # TODO: Check hints
  end
end
