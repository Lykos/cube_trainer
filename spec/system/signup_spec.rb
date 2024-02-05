# frozen_string_literal: true

require 'rails_helper'

# TODO: Doesn't work on github for some reason.
describe 'signup' do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then login' do
    visit ''
    click_link_or_button 'Sign Up'

    fill_in 'Username', with: 'system test user'
    fill_in 'Email', with: 'system_test+signup@example.org'
    find_by_id('password').fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    find_by_id('cube-trainer-terms-and-conditions-accepted').set(true)
    find_by_id('cube-trainer-privacy-policy-accepted').set(true)
    find_by_id('cube-trainer-cookie-policy-accepted').set(true)
    click_link_or_button_or_button 'Submit'

    expect(page).to have_text('Signup successful!')

    confirmation_email = ActionMailer::Base.deliveries.last
    confirm_path = extract_first_link_path(confirmation_email)
    expect(confirm_path).to start_with('/api/auth/confirmation')

    # TODO: Fix this
    # visit confirm_path
    # expect(page).to have_text('Email Confirmed')
    # TODO: Remove this
    user = User.find_by!(email: 'system_test+signup@example.org')
    user.confirm

    # Note that the password can't be read from the database, so we create the user manually.
    user = User.new(name: 'system test user', email: 'system_test+signup@example.org', password: 'password')
    login(user)
    expect(page).to have_text('system test user')
    expect(page).to have_text('Logout')
  end
end
