#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/buffer_helper'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/trainer'

options = CubeTrainer::Training::CommutatorOptions.parse(ARGV)
results_persistence = CubeTrainer::Training::ResultsPersistence.create_for_production
results_model = CubeTrainer::Training::ResultsModel.new(
  CubeTrainer::BufferHelper.mode_for_options(options), results_persistence
)
generator = options.commutator_info.generator_class.new(results_model, options)
learner = options.commutator_info.learner_class.new(generator.hinter, results_model, options)
stats_computer = CubeTrainer::Training::StatsComputer.new(Time.now, options, results_persistence)

stats = stats_computer.input_stats(generator.input_items)
puts "#{stats[:found]} of #{stats[:total]} items found, #{stats[:newish_elements]} of them " \
     "newish, #{stats[:missing]} missing."
puts "#{stats_computer.num_results} results, #{stats_computer.num_recent_results} of them in the " \
     'last 24 hours.'

CubeTrainer::Trainer.new(learner, results_model, generator.input_sampler).run
