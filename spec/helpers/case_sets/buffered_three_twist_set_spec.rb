# frozen_string_literal: true

require 'rails_helper'
require 'case_sets/three_twist_set'
require 'case_sets/buffered_three_twist_set'

describe CaseSets::BufferedThreeTwistSet do
  include_context 'with user abc'

  let(:three_twist_set) { CaseSets::ThreeTwistSet.new }
  let(:ufr) { TwistyPuzzles::Corner.for_face_symbols(%i[U F R]) }
  let(:urb) { TwistyPuzzles::Corner.for_face_symbols(%i[U R B]) }
  let(:ubl) { TwistyPuzzles::Corner.for_face_symbols(%i[U B L]) }
  let(:rbu) { TwistyPuzzles::Corner.for_face_symbols(%i[R B U]) }
  let(:blu) { TwistyPuzzles::Corner.for_face_symbols(%i[B L U]) }
  let(:buffered_three_twist_set) { three_twist_set.refinement(ufr) }
  let(:letter_scheme) do
    letter_scheme = LetterScheme.find_or_initialize_by(
      user: user
    )
    letter_scheme.save!
    letter_scheme.mappings.create!(part: rbu, letter: 'I')
    letter_scheme.mappings.create!(part: blu, letter: 'Q')
    letter_scheme
  end

  let(:ufr_urb_ubl_cw) do
    Case.new(
      part_cycles: [
        TwistyPuzzles::PartCycle.new([ufr], 2),
        TwistyPuzzles::PartCycle.new([urb], 2),
        TwistyPuzzles::PartCycle.new([ubl], 2)
      ]
    )
  end

  it 'generates the right case name' do
    expect(buffered_three_twist_set.case_name(ufr_urb_ubl_cw, letter_scheme: letter_scheme)).to eq('I Q')
  end
end
