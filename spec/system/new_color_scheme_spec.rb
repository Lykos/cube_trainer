# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'

describe 'new color scheme', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new color scheme' do
    login(user)
    visit '/modes'
    click_link user.name
    click_button 'Create Color Scheme'

    sleep(0.5)
    mat_select 'Yellow', id: 'colorSelectU'
    mat_select 'Red', id: 'colorSelectF'
    mat_select 'Green', id: 'colorSelectR'
    mat_select 'Blue', id: 'colorSelectL'
    mat_select 'Orange', id: 'colorSelectB'
    mat_select 'White', id: 'colorSelectD'

    sleep(0.5)
    click_button 'Submit'

    sleep(1)
    expect(page).to have_text('Color scheme created!')
  end
end
