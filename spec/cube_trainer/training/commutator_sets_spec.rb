# frozen_string_literal: true

require 'twisty_puzzles'
require 'rails_helper'

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
    mode.memo_time_s = 1.second if mode_type.has_memo_time?
    mode.test_comms_mode = :fail
    mode.validate!
    mode
  end
  let(:generator) { mode.generator }
  let(:input_items) { mode.input_items }

  it 'has input items if the mode type has bounded inputs' do
    expect(mode.input_items).not_to be_empty if mode_type.has_bounded_inputs?
  end
end

describe 'CommutatorSets' do
  TrainingSessionType.all.each do |mode_type|
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
