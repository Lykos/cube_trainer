require 'rails_helper'

describe 'signup', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'enables users to sign up and then login' do
    visit '/signup'

    fill_in 'Username', :with => 'system test user'
    fill_in 'Email', :with => 'system_test@example.org'
    fill_in 'Password', :with => 'password'
    fill_in 'Confirm Password', :with => 'password'
    click_button 'Submit'
    expect(page).to have_text('Signup successful!')

    fill_in 'Username', :with => 'system test user'
    fill_in 'Password', :with => 'password'
    click_button 'Submit'
    expect(page).to have_text('system test user')
    expect(page).to have_text('Logout')
  end
end
