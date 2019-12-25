require 'trainer'
require 'results_persistence'
require 'input_item'
require 'results_model'
require 'learner'
require 'commutator_sets'
require 'options'
require 'stats_computer'
require 'letter_pair'

ITERATIONS = 300

def compute_average(results_model, generator)
    learner = Learner.new
    trainer = Trainer.new(learner, results_model, generator)
    ITERATIONS.times { trainer.one_iteration }
    raise "Not all inputs covered." unless learner.items_learned == generator.items.length
    learner.average_time
end

describe  do
  ITEMS = ('a'..'c').to_a.permutation(2).collect { |p| InputItem.new(LetterPair.new(p)) }
  
  it "should perform better than random sampling" do
    results_persistence = ResultsPersistence.create_in_memory
    results_model = ResultsModel.new(:items, results_persistence)
    smart_sampler = InputSampler.new(ITEMS, results_model, 1.0)
    smart_average = compute_average(results_model, smart_sampler)

    results_persistence = ResultsPersistence.create_in_memory
    results_model = ResultsModel.new(:items, results_persistence)
    random_sampler = RandomSampler.new(ITEMS)
    random_average = compute_average(results_model, random_sampler)

    expect(smart_average).to be < random_average
  end
end

