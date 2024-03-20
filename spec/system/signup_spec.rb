# frozen_string_literal: true

require 'rails_helper'

describe 'signup' do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then login' do
    visit ''
    click_link_or_button 'Sign Up'

    fill_in 'Username', with: 'signup test user'
    fill_in 'Email', with: 'system_test+signup@example.org'
    find_by_id('password').fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    mat_checkbox(id: 'cube-trainer-terms-and-conditions-accepted')
    mat_checkbox(id: 'cube-trainer-privacy-policy-accepted')
    mat_checkbox(id: 'cube-trainer-cookie-policy-accepted')
    click_link_or_button 'Submit'

    expect(page).to have_text('Signup successful!')

    confirmation_email = ActionMailer::Base.deliveries.last
    confirm_path = extract_first_link_path(confirmation_email)
    expect(confirm_path).to start_with('/api/auth/confirmation')

    visit replaced_redirect_url(confirm_path)
    expect(page).to have_text('Email Confirmed')
    user = User.find_by!(email: 'system_test+signup@example.org')
    expect(user).to be_confirmed

    # Note that the password can't be read from the database, so we create the user manually.
    user = User.new(name: 'signup test user', email: 'system_test+signup@example.org', password: 'password')
    login(user)
    expect(page).to have_text('signup test user')
    expect(page).to have_text('Logout')
  end
end
