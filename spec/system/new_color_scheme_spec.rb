# frozen_string_literal: true

require 'rails_helper'

describe 'new color scheme' do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new color scheme' do
    login(user)

    click_link user.name
    click_link 'Create Color Scheme'

    mat_select 'Yellow', id: 'colorSelectU'
    mat_select 'Red', id: 'colorSelectF'

    click_button 'Submit'

    expect(page).to have_text('Color scheme created.')
  end
end
