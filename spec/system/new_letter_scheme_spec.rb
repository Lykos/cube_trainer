# frozen_string_literal: true

require 'rails_helper'

describe 'new letter scheme', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new letter scheme' do
    login(user)

    visit '/modes'
    click_link user.name
    click_link 'Create Letter Scheme'

    sleep(0.5)
    fill_in 'ULB', with: 'A'

    sleep(0.5)
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Letter scheme created!')
  end
end
