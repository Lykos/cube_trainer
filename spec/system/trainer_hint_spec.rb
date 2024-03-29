# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

def expected_alg(case_string)
  case case_string
  when 'UR UL' then "M2 U M U2 M' U M2"
  when 'UL UR' then "M2 U' M U2 M' U' M2"
  when 'RU UL' then "[R' F R, S]"
  when 'UL RU' then "[S, R' F R]"
  when 'LU UR' then "[L F' L', S']"
  when 'UR LU' then "[S', L F' L']"
  when 'RU LU' then "M U' M' U2 M U' M'"
  when 'LU RU' then "M U M' U2 M U M'"
  else raise
  end
end

def alternative_alg(case_string)
  case case_string
  when 'UR UL' then '[M2 : [U / M]]'
  when 'UL UR' then "[M2 : [U' / M]]"
  when 'RU UL' then "R' F R S R' F' R S'"
  when 'UL RU' then "S R' F R S' R' F' R"
  when 'LU UR' then "L F' L' S' L F L' S"
  when 'UR LU' then "S' L F' L' S L F L'"
  when 'RU LU' then "[M : [U' / M']]"
  when 'LU RU' then "[M : [U / M']]"
  else raise
  end
end

describe 'trainer hint' do
  include_context 'with user abc'
  include_context 'with alg set'

  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.window.resize_to(1920, 1080)
  end

  let(:case_regexp) do
    # One of the cases from this alg set should be picked.
    /UR UL|UL UR|RU UL|UL RU|LU UR|UR LU|RU LU|LU RU/
  end

  let(:training_session) do
    training_session = user.training_sessions.find_or_initialize_by(
      name: 'restricted_test_training_session'
    )
    exclude_parts = [%i[U B], %i[F R], %i[F L], %i[F D], %i[B R], %i[D R], %i[B L], %i[D L], %i[D B]]
    training_session.show_input_mode = :name
    training_session.training_session_type = :edge_commutators
    training_session.buffer = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    training_session.exclude_parts = exclude_parts.map { |e| TwistyPuzzles::Edge.for_face_symbols(e) }
    training_session.goal_badness = 1.0
    training_session.cube_size = 3
    training_session.known = false
    training_session.exclude_algless_parts = false
    training_session.alg_set = alg_set
    training_session.save!
    training_session
  end

  it 'allows to see hints' do
    login(user)

    visit "/training-sessions/#{training_session.id}"

    click_link_or_button 'Start'
    picked_case =
      within('.case') do
        expect(page).to have_text(case_regexp)
        page.text[case_regexp]
      end
    click_link_or_button 'Reveal'
    within('.alg') do
      expect(page).to have_text(expected_alg(picked_case))
    end
  end

  it 'allows to override hints' do
    login(user)

    visit "/training-sessions/#{training_session.id}"

    click_link_or_button 'Start'
    picked_case =
      within('.case') do
        expect(page).to have_text(case_regexp)
        page.text[case_regexp]
      end
    click_link_or_button 'Reveal'
    click_link_or_button 'Override'
    find_by_id('override-alg-input').fill_in 'Alg Override', with: alternative_alg(picked_case)
    within('#override-alg-dialog') { click_link_or_button 'Override' }
    expect(page).to have_text("Alg for #{picked_case} overridden")

    expect(training_session.alg_overrides.count).to be(1)
  end
end
