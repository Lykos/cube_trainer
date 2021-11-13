# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'
require 'fixtures'

describe 'new letter scheme', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new letter scheme' do
    login(user)
    click_button user.name
    click_button 'Create Letter Scheme'

    sleep(0.5)
    fill_in 'ULB', with: 'A'
    fill_in 'letterSchemeName', with: 'system test letter scheme'

    sleep(0.5)
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Letter scheme system test letter scheme created!')
  end
end
