# frozen_string_literal: true

require 'cube_trainer/training/commutator_sets'
require 'rails_helper'

BROKEN_MODE_TYPE_NAMES = [
  :corner_twists_plus_parities_ul_ub,
  :corner_3twists,
  :floating_2twists_and_corner_3twists
]

shared_examples 'commutator_set' do |mode_type|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:mode) do
    Mode.new(
      mode_type: mode_type,
      cube_size: mode_type.default_cube_size,
    )
  end
  let(:generator) { mode.generator }
  let(:input_items) { mode.input_items }
  let(:hinter) { mode.hinter }

  it 'parses all comms correctly and give a hint on a random one' do
    skip if BROKEN_MODE_TYPE_NAMES.include?(mode_type.name)
    if input_items
      input_item = input_items.sample
      hinter.hints(input_item.representation)
    end
  end
end

ModeType::ALL.each do |mode_type|
  next unless mode_type.default_cube_size

  describe mode_type.generator_class do
    it_behaves_like 'commutator_set', mode_type
  end
end
