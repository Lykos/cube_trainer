#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutator_sets'
require 'options'
require 'results_model'
require 'trainer'
require 'buffer_helper'
require 'stats_computer'

include CubeTrainer

options = Options.parse(ARGV)
results_persistence = ResultsPersistence.create_for_production
results_model = ResultsModel.new(BufferHelper.mode_for_options(options), results_persistence)
generator = options.commutator_info.generator_class.new(results_model, options)
learner = options.commutator_info.learner_class.new(generator.hinter, results_model, options)
stats_computer = StatsComputer.new(options, results_persistence)

stats = stats_computer.input_stats(generator.input_items)
puts "#{stats[:found]} of #{stats[:total]} items found, #{stats[:newish_elements]} of them newish, #{stats[:missing]} missing."
puts "#{stats_computer.num_results} results, #{stats_computer.num_recent_results} of them in the last 24 hours."

Trainer.new(learner, results_model, generator.input_sampler).run

