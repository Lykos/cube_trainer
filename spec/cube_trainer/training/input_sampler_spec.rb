# frozen_string_literal: true

require 'cube_trainer/training/fake_learner'
require 'cube_trainer/training/trainer'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/input_sampler'
require 'cube_trainer/letter_pair'
require 'ostruct'
require 'rails_helper'
require 'twisty_puzzles'

ITERATIONS = 300

def compute_average(training_session, generator)
  Result.delete_all
  learner = FakeLearner.new
  trainer = Training::Trainer.new(learner, training_session, generator)
  ITERATIONS.times { trainer.one_iteration }
  raise 'Not all inputs covered.' unless learner.items_learned == generator.items.length

  learner.average_time
end

def casee(*parts)
  Case.new(part_cycles: [TwistyPuzzles::PartCycle.new(parts)])
end

describe Training::InputSampler do
  include_context 'with training session'
  include_context 'with edges'

  let(:cases) do
    [
      casee(uf, ub, ur),
      casee(uf, ub, ul),
      casee(uf, ur, ub),
      casee(uf, ur, ul),
      casee(uf, ul, ub),
      casee(uf, ul, ur)
    ]
  end

  let(:items) { cases.map { |c| Training::InputItem.new(c) } }

  it 'performs better than random sampling' do
    smart_sampler = described_class.new(items, training_session)
    smart_average = compute_average(training_session, smart_sampler)

    random_sampler = Training::RandomSampler.new(items)
    random_average = compute_average(training_session, random_sampler)

    expect(smart_average).to be < random_average
  end
end
