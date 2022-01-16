# frozen_string_literal: true

require 'rails_helper'

# TODO: Doesn't work on github for some reason.
describe 'signup', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then login' do
    visit ''
    click_link 'Sign Up'

    fill_in 'Username', with: 'system test user'
    fill_in 'Email', with: 'system_test+signup@example.org'
    find('#password').fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    find(:css, '#cube-trainer-terms-and-conditions-accepted').set(true)
    find(:css, '#cube-trainer-privacy-policy-accepted').set(true)
    find(:css, '#cube-trainer-cookie-policy-accepted').set(true)
    click_button 'Submit'

    expect(page).to have_text('Signup successful!')

    confirmation_email = ActionMailer::Base.deliveries.last
    confirm_path = extract_first_link_path(confirmation_email)
    expect(confirm_path).to start_with('/api/auth/confirmation')

    visit confirm_path
    expect(page).to have_text('Email Confirmed')

    # Note that this can't be read from the database
    user = User.new(email: 'system_test+signup@example.org', password: 'password')
    login(user)
    expect(page).to have_text('system test user')
    expect(page).to have_text('Logout')
  end
end
