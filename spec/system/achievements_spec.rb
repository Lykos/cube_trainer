# frozen_string_literal: true

require 'rails_helper'

describe 'achievements' do
  include_context 'with user abc'
  include_context 'with achievement grant'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to view achievements' do
    achievement_grant
    login(user)
    click_link_or_button user.name

    find('cube-trainer-achievement-grants td', text: achievement_grant.achievement.name).click
    expect(page).to have_text('Fake achievement for tests.')
    click_link_or_button 'All Achievements'

    expect(page).to have_text('Training Session Creator')
  end
end
