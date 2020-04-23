# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'
require 'fixtures'

describe 'messages', type: :system do
  include_context :user
  include_context :achievement_grant

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to view achievements' do
    achievement_grant
    visit '/login'
    login(user)
    click_button user.name

    find('achievement-grants td', text: achievement_grant.achievement.name).click
    expect(page).to have_text('Fake achievement for tests.')
    click_button 'All Achievements'

    expect(page).to have_text('Mode Creator')
  end
end
