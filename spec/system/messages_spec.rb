# frozen_string_literal: true

require 'rails_helper'
require 'system/system_spec_helper'
require 'fixtures'

describe 'messages', type: :system do
  include_context 'with user abc'
  include_context 'with message'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to read messages' do
    user_message
    login(user)
    click_button user.name

    find('cube-trainer-messages td', text: user_message.title).click
    expect(page).to have_text(user_message.body)
  end
end
