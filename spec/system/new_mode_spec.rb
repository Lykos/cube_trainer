require 'rails_helper'
require 'system_test_helper'

xdescribe 'modes', type: :system do
  include_context :logged_in

  it 'allows to create a new mode' do
    click_button 'New'

    fill_in 'Name', with: 'system test mode'
    mat_select 'Corner Commutators', from: 'modeType'
    click_button 'Next'

    fill_in 'Cube Size', with: '3'
    mat_select 'ULB', from: 'buffer'
    click_button 'Next'

    mat_select 'name', from: 'showInputMode'
    fill_in 'Goal Time Per Element', with: '2.0'
    click_button 'Next'

    click_button 'Submit'
    expect(page).to have_text('Mode system test mode Created!')
  end
end
