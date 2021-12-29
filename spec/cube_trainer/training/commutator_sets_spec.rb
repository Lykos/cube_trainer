# frozen_string_literal: true

require 'twisty_puzzles'
require 'rails_helper'

shared_examples 'commutator_set' do |training_session_type, buffer|
  include_context 'with user abc'

  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:training_session) do
    training_session = user.training_sessions.new(
      name: training_session_type,
      show_input_mode: :name,
      training_session_type: training_session_type,
      cube_size: training_session_type.default_cube_size,
      buffer: buffer
    )
    training_session.memo_time_s = 1.second if training_session_type.has_memo_time?
    training_session.test_comms_mode = :fail
    training_session.validate!
    training_session
  end
  let(:generator) { training_session.generator }
  let(:input_items) { training_session.input_items }

  it 'has input items if the training_session type has bounded inputs' do
    if training_session_type.has_bounded_inputs?
      expect(training_session.input_items).not_to be_empty
    end
  end
end

describe 'CommutatorSets' do
  TrainingSessionType.all.each do |training_session_type|
    next unless training_session_type.default_cube_size

    describe training_session_type.generator_class do
      if training_session_type.has_buffer?
        buffers = training_session_type.generator_class.buffers_with_hints
        buffers.each do |buffer|
          describe "for buffer #{buffer}" do
            it_behaves_like 'commutator_set', training_session_type, buffer
          end
        end
      else
        it_behaves_like 'commutator_set', training_session_type, nil
      end
    end
  end
end
