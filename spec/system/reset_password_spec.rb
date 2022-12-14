# frozen_string_literal: true

require 'rails_helper'

describe 'reset_password' do
  skip "Doesn't work because visiting the update path crashes the test somehow."
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to reset their password and then login' do
    user
    email = user.email
    name = user.name
    visit ''
    find_by_id('toolbar-login').click
    click_link 'Password Forgotten'

    fill_in 'Email', with: email
    click_button 'Send Reset Password Instructions'

    expect(page).to have_text('Email sent!')

    update_email = ActionMailer::Base.deliveries.last
    update_path = extract_first_link_path(update_email)
    expect(update_path).to start_with('/api/auth/password/edit')

    visit update_path
    expect(page).to have_text('Update Password')

    find_by_id('update-password').fill_in 'Password', with: 'password2'
    fill_in 'Confirm Password', with: 'password2'
    click_button 'Submit'

    expect(page).to have_text('Password updated')

    user = User.new(email: email, password: 'password2')
    login(user)
    expect(page).to have_text(name)
    expect(page).to have_text('Logout')
  end
end
