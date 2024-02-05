# frozen_string_literal: true

require 'rails_helper'

describe 'new letter scheme' do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new letter scheme' do
    login(user)

    click_link_or_button user.name
    click_link_or_button 'Create Letter Scheme'

    fill_in 'ULB', with: 'A'
    fill_in 'URF', with: 'B'

    click_link_or_button_or_button 'Submit'

    expect(page).to have_text('Letter scheme created!')
  end
end
