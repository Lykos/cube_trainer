# frozen_string_literal: true

require 'cube_trainer/training/fake_learner'
require 'cube_trainer/training/trainer'
require 'cube_trainer/training/results_persistence'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/results_model'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/stats_computer'
require 'cube_trainer/letter_pair'
require 'ostruct'

ITERATIONS = 300

def compute_average(results_model, generator)
  learner = FakeLearner.new
  trainer = Training::Trainer.new(learner, results_model, generator)
  ITERATIONS.times { trainer.one_iteration }
  raise 'Not all inputs covered.' unless learner.items_learned == generator.items.length

  learner.average_time
end

describe Training::InputSampler do
  ITEMS = ('a'..'c').to_a.permutation(2).map { |p| Training::InputItem.new(LetterPair.new(p)) }

  let(:options) { OpenStruct.new }

  it 'performs better than random sampling' do
    results_persistence = Training::ResultsPersistence.create_in_memory
    results_model = Training::ResultsModel.new(:items, results_persistence)

    smart_sampler = described_class.new(ITEMS, results_model, options, 1.0)
    smart_average = compute_average(results_model, smart_sampler)

    results_persistence = Training::ResultsPersistence.create_in_memory
    results_model = Training::ResultsModel.new(:items, results_persistence)
    random_sampler = Training::RandomSampler.new(ITEMS)
    random_average = compute_average(results_model, random_sampler)

    expect(smart_average).to be < random_average
  end
end
