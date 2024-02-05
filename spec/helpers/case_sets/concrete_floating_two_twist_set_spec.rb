# frozen_string_literal: true

require 'rails_helper'
require 'case_sets/abstract_floating_two_twist_set'
require 'case_sets/concrete_floating_two_twist_set'

describe CaseSets::ConcreteFloatingTwoTwistSet do
  include_context 'with user abc'

  let(:abstract_floating_two_twist_set) { CaseSets::AbstractFloatingTwoTwistSet.new(TwistyPuzzles::Corner) }
  let(:ufr) { TwistyPuzzles::Corner.for_face_symbols(%i[U F R]) }
  let(:ruf) { TwistyPuzzles::Corner.for_face_symbols(%i[R U F]) }
  let(:urb) { TwistyPuzzles::Corner.for_face_symbols(%i[U R B]) }
  let(:rbu) { TwistyPuzzles::Corner.for_face_symbols(%i[R B U]) }
  let(:concrete_floating_two_twist_set) { abstract_floating_two_twist_set.refinement }
  let(:letter_scheme) do
    letter_scheme = LetterScheme.find_or_initialize_by(
      user: user
    )
    letter_scheme.save!
    letter_scheme.mappings.create!(part: rbu, letter: 'I')
    letter_scheme.mappings.create!(part: ruf, letter: 'J')
    letter_scheme
  end

  let(:ufr_ccw_urb_cw) do
    Case.new(
      part_cycles: [
        TwistyPuzzles::PartCycle.new([ufr], 1),
        TwistyPuzzles::PartCycle.new([urb], 2)
      ]
    )
  end

  it 'generates the right case name' do
    expect(concrete_floating_two_twist_set.case_name(ufr_ccw_urb_cw, letter_scheme: letter_scheme)).to eq('J I')
  end
end
