# frozen_string_literal: true

require 'rails_helper'

def extract_first_link_path(email)
  puts email.html_part.body
  email.html_part.body.match(%r{(?:"https?://.*?)(/.*?)(?:")}).captures[0]
end

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
    click_button 'Submit'

    expect(page).to have_text('Signup successful!')

    user = User.find_by(name: 'system test user')
    user.update(admin_confirmed: true)

    confirmation_email = ActionMailer::Base.deliveries.last
    confirm_path = extract_first_link_path(confirmation_email)

    visit confirm_path
    expect(page).to have_text('Email Confirmed')
    first(:link, 'Login').click

    fill_in 'Username', with: 'system test user'
    fill_in 'Password', with: 'password'
    click_button 'Submit'
    expect(page).to have_text('system test user')
    expect(page).to have_text('Logout')
  end
end
