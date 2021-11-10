# frozen_string_literal: true

require 'twisty_puzzles'
require 'rails_helper'
require 'fixtures'

shared_examples 'commutator_set' do |mode_type, buffer|
  include_context 'with user abc'

  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:mode) do
    mode = user.modes.new(
      name: mode_type,
      show_input_mode: :name,
      mode_type: mode_type,
      cube_size: mode_type.default_cube_size,
      buffer: buffer
    )
    if mode_type.has_parity_parts?
      mode.first_parity_part = TwistyPuzzles::Edge.for_face_symbols(%i[U B])
      mode.second_parity_part = TwistyPuzzles::Edge.for_face_symbols(%i[U R])
    end
    mode.memo_time_s = 1.second if mode_type.has_memo_time?
    mode.test_comms_mode = :fail
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
  ModeType.all.each do |mode_type|
    next unless mode_type.default_cube_size

    describe mode_type.generator_class do
      if mode_type.has_buffer?
        buffers = mode_type.generator_class.buffers_with_hints
        buffers.each do |buffer|
          describe "for buffer #{buffer}" do
            it_behaves_like 'commutator_set', mode_type, buffer
          end
        end
      else
        it_behaves_like 'commutator_set', mode_type, nil
      end
    end
  end
end
