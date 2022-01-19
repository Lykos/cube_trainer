# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

describe 'trainer', type: :system do
  include_context 'with user abc'
  include_context 'with edges'
  include_context 'with alg spreadsheet'

  before do
    driven_by(:selenium_chrome_headless)
  end

  let(:case_set) do
    CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, uf)
  end

  let(:alg_set) do
    alg_set = alg_spreadsheet.alg_sets.create!(case_set: case_set, sheet_title: 'test sheet')
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ur, ul])]
      ),
      alg: "M2 U M U2 M' U M2",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ul, ur])]
      ),
      alg: "M2 U' M U2 M' U' M2",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ru, ul])]
      ),
      alg: "[R' F R, S]",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ul, ru])]
      ),
      alg: "[S, R' F R]",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, lu, ur])]
      ),
      alg: "[L F L', S']",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ur, lu])]
      ),
      alg: "[S', L F L']",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ru, lu])]
      ),
      alg: "M U' M' U2 M U' M'",
    )
    alg_set.algs.create(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, lu, ru])]
      ),
      alg: "M U M' U2 M U M'",
    )
    alg_set
  end

  let(:training_session) do
    training_session = user.training_sessions.find_or_initialize_by(
      name: 'restricted_test_training_session'
    )
    training_session.show_input_mode = :name
    training_session.training_session_type = :edge_commutators
    training_session.buffer = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    training_session.goal_badness = 1.0
    training_session.cube_size = 3
    training_session.known = false
    training_session.exclude_algless_parts = true
    training_session.alg_set = alg_set
    training_session.save!
    training_session
  end

  it 'allows to train' do
    login(user)

    # TODO: Figure out how to identify the right button in the training_session list.

    visit "/training-sessions/#{training_session.id}"

    click_button 'Start'
    click_button 'Stop and Start'
    click_button 'Stop and Pause'

    # TODO: Check hints
  end
end
