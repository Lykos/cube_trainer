# frozen_string_literal: true

require 'cube_trainer/training/commutator_sets'
require 'ostruct'
require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/stub_results_model'

shared_examples 'commutator_set' do |info|
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:options) do
    options = Training::CommutatorOptions.default_options
    options.commutator_info = info
    options.cube_size = info.default_cube_size
    options.test_comms_mode = :fail
    options
  end
  let(:results_model) { StubResultsModel.new }
  let(:generator) { info.generator_class.new(options) }
  let(:input_items) { generator.input_items }
  let(:hinter) { generator.hinter(results_model) }

  it 'parses all comms correctly and give a hint on the first one' do
    input_item = input_items.sample
    hinter.hints(input_item.representation)
  end
end

Training::CommutatorOptions::COMMUTATOR_TYPES.each do |_key, info|
  next unless info.default_cube_size

  describe info.generator_class do
    it_behaves_like 'commutator_set', info
  end
end
