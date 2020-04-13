# frozen_string_literal: true

require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/core/cube'
require 'rails_helper'
require 'fixtures'

shared_examples 'commutator_set' do |mode_type|
  include_context :user

  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:mode) do
    mode = user.modes.new(
      name: mode_type,
      show_input_mode: :name,
      mode_type: mode_type,
      cube_size: mode_type.default_cube_size,
    )
    mode.buffer = mode.letter_scheme.default_buffer(mode.part_type) if mode_type.has_buffer?
    if mode_type.has_parity_parts?
      mode.first_parity_part = CubeTrainer::Core::Edge.for_face_symbols([:U, :B])
      mode.second_parity_part = CubeTrainer::Core::Edge.for_face_symbols([:U, :R])
    end
    mode.validate!
    mode
  end
  let(:generator) { mode.generator }
  let(:input_items) { mode.input_items }
  let(:hinter) { mode.hinter }

  it 'parses all comms correctly and give a hint on a random one' do
    if input_items
      input_item = input_items.sample
      hinter.hints(input_item.representation)
    end
  end
end

describe 'CommutatorSets' do
  ModeType::ALL.each do |mode_type|
    next unless mode_type.default_cube_size

    describe mode_type.generator_class do
      it_behaves_like 'commutator_set', mode_type
    end
  end
end
