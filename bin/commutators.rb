# frozen_string_literal: true

require 'cube_trainer/buffer_helper'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/trainer'

options = CubeTrainer::Training::CommutatorOptions.parse(ARGV)
results_model = CubeTrainer::Training::ResultsModel.new(
  CubeTrainer::BufferHelper.mode_for_options(options)
)
generator = options.commutator_info.generator_class.new(options)
hinter = generator.hinter
learner = options.commutator_info.learner_class.new(hinter, results_model, options)
stats_computer = CubeTrainer::Training::StatsComputer.new(Time.now, options)

if generator.input_items
  stats = stats_computer.input_stats(generator.input_items)
  puts "#{stats[:found]} of #{stats[:total]} items found, #{stats[:newish_elements]} of them " \
       "newish, #{stats[:missing]} missing."
  puts "#{stats_computer.num_results} results, #{stats_computer.num_recent_results} of them in " \
       'the last 24 hours.'
end

input_sampler = generator.input_sampler(results_model)
CubeTrainer::Training::Trainer.new(learner, results_model, input_sampler).run
