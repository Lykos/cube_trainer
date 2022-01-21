# frozen_string_literal: true

require 'rails_helper'

describe 'account deletion', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then delete their account' do
    user = User.find_or_initialize_by(name: 'account deletion user')
    user.update(
      email: 'system_test+account_deletion@example.org',
      provider: 'email',
      uid: 'system_test+account_deletion@example.org',
      admin_confirmed: true,
      email_confirmed: true,
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
    user.confirm

    login(user)

    click_link user.name
    within('#delete-account-div') { click_button 'Delete Account' }
    within('#delete-account-confirmation-dialog') { click_button 'Ok' }

    expect(page).to have_text('Account Deleted')
    expect(User.find_by(name: 'system test user')).to be_nil
  end
end
