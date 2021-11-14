# frozen_string_literal: true

require 'cube_trainer/training/fake_learner'
require 'cube_trainer/training/trainer'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/stats_computer'
require 'cube_trainer/letter_pair'
require 'ostruct'

ITERATIONS = 300

def compute_average(mode, generator)
  Result.delete_all
  learner = FakeLearner.new
  trainer = Training::Trainer.new(learner, mode, generator)
  ITERATIONS.times { trainer.one_iteration }
  raise 'Not all inputs covered.' unless learner.items_learned == generator.items.length

  learner.average_time
end

describe Training::InputSampler do
  include_context 'with mode'

  let(:items) do
    ('a'..'c').to_a.permutation(2).map { |p| Training::InputItem.new(LetterPair.new(p)) }
  end

  it 'performs better than random sampling' do
    smart_sampler = described_class.new(items, mode)
    smart_average = compute_average(mode, smart_sampler)

    random_sampler = Training::RandomSampler.new(items)
    random_average = compute_average(mode, random_sampler)

    expect(smart_average).to be < random_average
  end
end
