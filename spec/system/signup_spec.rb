# frozen_string_literal: true

require 'rails_helper'

describe 'signup', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then login' do
    visit ''
    click_link 'Sign Up'

    fill_in 'Username', with: 'system test user'
    fill_in 'Email', with: 'system_test@example.org'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    check 'cube-trainer-terms-and-conditions-accepted'
    check 'cube-trainer-privacy-policy-accepted'
    check 'cube-trainer-cookie-policy-accepted'
    click_button 'Submit'

    expect(page).to have_text('Signup successful!')

    confirmation_email = ActionMailer::Base.deliveries.last
    confirm_path = extract_first_link_path(confirmation_email)
    expect(confirm_path).to start_with('/api/auth/confirmation')

    # TODO: Instead, just use `visit confirm_path`
    # Doesn't work due to some connection errors.
    user = User.find_by(name: 'system test user')
    user.admin_confirm!
    user.confirm
    user.password = 'password'

    login(user)
    expect(page).to have_text('system test user')
    expect(page).to have_text('Logout')
  end
end
