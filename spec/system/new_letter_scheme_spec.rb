# frozen_string_literal: true

require 'rails_helper'

describe 'new letter scheme', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new letter scheme' do
    login(user)

    visit '/training-sessions'
    click_link user.name
    click_link 'Create Letter Scheme'

    fill_in 'ULB', with: 'A'
    fill_in 'URF', with: 'B'

    click_button 'Submit'

    expect(page).to have_text('Letter scheme created!')
  end
end
