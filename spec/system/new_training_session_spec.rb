# frozen_string_literal: true

require 'rails_helper'

# We sleep before clicking 'Next' in the mat-stepper.
# Sleep is ugly and we hate it, but we have done everything we could think of
# and at this point we don't understand why it's flaky without sleep.
# What we did to make sure that in theory we shouldn't need sleep:
# * Always use Capybara matchers that implicitly wait.
# * Make sure the 'Next' button is disabled in the frontend before it's ready to be clicked.
# * Introduce some fake HTML elements containing the entered data and
#   check if the entered form data has arrived there. This should avoid problem where the data
#   hasn't propagated yet.
def before_next_sleep
  sleep(0.5)
end

describe 'new training session' do
  include_context 'with user abc'
  include_context 'with alg set'

  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows to create a new commutator training session with algs' do
    alg_set
    login(user)

    visit '/training-sessions'
    click_link_or_button 'Cube Trainer'
    click_link_or_button_or_button 'New'

    fill_in 'Name', with: 'system test training session'
    mat_select 'Edge Commutators', from: 'trainingSessionType'
    expect(find_by_id('training-session-type-id', visible: :all)).to have_text(:all, 'edge_commutators')
    before_next_sleep
    within('#training-session-type-group-actions') { click_link_or_button_or_button 'Next' }

    mat_select 'UF', from: 'buffer'
    expect(find_by_id('buffer', visible: :all)).to have_text(:all, 'UF')
    before_next_sleep
    within('#setup-group-actions') { click_link_or_button_or_button 'Next' }

    mat_select 'Testy Testikow', id: 'alg-set-select'
    expect(find_by_id('alg-set-id', visible: :all)).to have_text(:all, alg_set.id.to_s)
    before_next_sleep
    within('#alg-set-group-actions') { click_link_or_button_or_button 'Next' }

    mat_select 'picture', from: 'showInputMode'
    fill_in 'Goal Time per Element', with: '2.0'
    expect(find_by_id('show-input-mode', visible: :all)).to have_text(:all, 'picture')
    expect(find_by_id('goal-badness', visible: :all)).to have_text(:all, '2')
    before_next_sleep
    within('#training-group-actions') { click_link_or_button_or_button 'Next' }

    # Not adding any stats because drag and drop is buggy with Selenium.
    before_next_sleep
    within('#stats-group-actions') { click_link_or_button_or_button 'Submit' }

    expect(page).to have_text('Session system test training session created.')
  end

  it 'allows to create a new commutator training session without algs' do
    login(user)

    visit '/training-sessions'
    click_link_or_button 'Cube Trainer'
    click_link_or_button_or_button 'New'

    fill_in 'Name', with: 'system test training session'
    mat_select 'Corner Commutators', from: 'trainingSessionType'
    expect(find_by_id('training-session-type-id', visible: :all)).to have_text(:all, 'corner_commutators')
    before_next_sleep
    within('#training-session-type-group-actions') { click_link_or_button_or_button 'Next' }

    within('#cube-size-input') do
      fill_in 'Cube Size', with: '3'
    end
    expect(find_by_id('cube-size', visible: :all)).to have_text(:all, '3')
    mat_select 'ULB', from: 'buffer'
    expect(find_by_id('buffer', visible: :all)).to have_text(:all, 'ULB')
    before_next_sleep
    within('#setup-group-actions') { click_link_or_button_or_button 'Next' }

    mat_select 'name', from: 'showInputMode'
    fill_in 'Goal Time per Element', with: '2.0'
    expect(find_by_id('show-input-mode', visible: :all)).to have_text(:all, 'name')
    expect(find_by_id('goal-badness', visible: :all)).to have_text(:all, '2')
    before_next_sleep
    within('#training-group-actions') { click_link_or_button_or_button 'Next' }

    # Not adding any stats because drag and drop is buggy with Selenium.
    before_next_sleep
    within('#stats-group-actions') { click_link_or_button_or_button 'Submit' }

    expect(page).to have_text('Session system test training session created.')
  end

  it 'allows to create a new memo rush training session' do
    login(user)

    visit '/training-sessions'
    click_link_or_button 'Cube Trainer'
    click_link_or_button_or_button 'New'

    fill_in 'Name', with: 'system test training session'
    mat_select 'Memo Rush', from: 'trainingSessionType'
    expect(find_by_id('training-session-type-id', visible: :all)).to have_text(:all, 'memo_rush')
    before_next_sleep
    within('#training-session-type-group-actions') { click_link_or_button_or_button 'Next' }

    within('#cube-size-input') do
      fill_in 'Cube Size', with: '3'
    end
    expect(find_by_id('cube-size', visible: :all)).to have_text(:all, '3')
    before_next_sleep
    within('#setup-group-actions') { click_link_or_button_or_button 'Next' }

    fill_in 'Memo Time', with: '20.0'
    expect(find_by_id('memo-time-s', visible: :all)).to have_text(:all, '20')
    before_next_sleep
    within('#training-group-actions') { click_link_or_button_or_button 'Next' }

    # Not adding any stats because drag and drop is buggy with Selenium.
    before_next_sleep
    within('#stats-group-actions') { click_link_or_button_or_button 'Submit' }

    expect(page).to have_text('Session system test training session created.')
  end
end
