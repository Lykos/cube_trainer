# frozen_string_literal: true

require 'rails_helper'

# TODO: Turn on once the snackbar works in system tests.
xdescribe 'reset_password', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to reset their password and then login' do
    user
    email = user.email
    name = user.name
    visit ''
    find('#toolbar-login').click
    click_link 'Password Forgotten'

    fill_in 'Email', with: email
    click_button 'Send Reset Password Instructions'

    expect(page).to have_text('Email sent!')

    update_email = ActionMailer::Base.deliveries.last
    update_path = extract_first_link_path(update_email)
    expect(update_path).to start_with('/api/auth/password/edit')

    visit update_path
    expect(page).to have_text('Update Password')

    find('#update-password').fill_in 'Password', with: 'password2'
    fill_in 'Confirm Password', with: 'password2'
    click_button 'Submit'

    expect(page).to have_text('Password updated')

    user = User.new(email: email, password: 'password2')
    login(user)
    expect(page).to have_text(name)
    expect(page).to have_text('Logout')
  end
end
