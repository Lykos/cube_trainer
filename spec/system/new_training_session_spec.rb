# frozen_string_literal: true

require 'rails_helper'

describe 'new training session', type: :system do
  include_context 'with user abc'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new commutator training session' do
    login(user)

    visit '/training-sessions'
    click_link 'Cube Trainer'
    click_button 'New'

    fill_in 'Name', with: 'system test training session'
    mat_select 'Corner Commutators', from: 'trainingSessionType'
    expect(find('#training-session-type-id', visible: :all)).to have_text(:all, 'corner_commutators')
    within('#training-session-type-group-actions') { click_button 'Next' }

    within('#cube-size-input') do
      fill_in 'Cube Size', with: '3'
    end
    mat_select 'ULB', from: 'buffer'
    expect(find('#cube-size', visible: :all)).to have_text(:all, '3')
    expect(find('#buffer', visible: :all)).to have_text(:all, 'ULB')
    within('#setup-group-actions') { click_button 'Next' }

    within('#alg-set-select') do
      expect(page).to have_text('Alg Set')
    end
    within('#alg-set-group-actions') { click_button 'Next' }

    mat_select 'name', from: 'showInputMode'
    fill_in 'Goal Time per Element', with: '2.0'
    expect(find('#show-input-mode', visible: :all)).to have_text(:all, 'name')
    expect(find('#goal-badness', visible: :all)).to have_text(:all, '2')
    within('#training-group-actions') { click_button 'Next' }

    # Not adding any stats because drag and drop is buggy with Selenium.
    within('#stats-group-actions') { click_button 'Submit' }

    expect(page).to have_text('Session system test training session created.')
  end

  it 'allows to create a new memo rush training session' do
    login(user)

    visit '/training-sessions'
    click_link 'Cube Trainer'
    click_button 'New'

    fill_in 'Name', with: 'system test training session'
    mat_select 'Memo Rush', from: 'trainingSessionType'
    expect(find('#training-session-type-id', visible: :all)).to have_text(:all, 'memo_rush')
    within('#training-session-type-group-actions') { click_button 'Next' }

    within('#cube-size-input') do
      fill_in 'Cube Size', with: '3'
    end
    expect(find('#cube-size', visible: :all)).to have_text(:all, '3')
    within('#setup-group-actions') { click_button 'Next' }

    fill_in 'Memo Time', with: '20.0'
    expect(find('#memo-time-s', visible: :all)).to have_text(:all, '20')
    within('#training-group-actions') { click_button 'Next' }

    # Not adding any stats because drag and drop is buggy with Selenium.
    within('#stats-group-actions') { click_button 'Submit' }

    expect(page).to have_text('Session system test training session created.')
  end
end
