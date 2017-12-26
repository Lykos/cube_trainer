#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'options'
require 'results_model'
require 'input_sampler'
require 'human_learner'
require 'trainer'

# TODO Do this in the UI.

options = Options.parse(ARGV)
results_model = ResultsModel.new(options.commutator_info.result_symbol)
generator = options.commutator_info.generator_class.new(results_model, options.restrict_letters)
learner = HumanLearner.new(generator.hinter, results_model)

# Move the stats stuff to somewhere else.
inputs = results_model.results.collect { |r| r.input }
newish_elements = inputs.group_by { |e| e }.collect { |k, v| v.length }.count { |l| 1 <= l && l < InputSampler::NEW_ITEM_BOUNDARY }
found = inputs.uniq.length
total = generator.class::VALID_PAIRS.length
missing = total - found
puts "#{found} words found, #{newish_elements} of them newish, #{missing} missing."
now = Time.now
recent_results = results_model.results.select { |r| r.timestamp > now - 24 * 3600 }
puts "#{results_model.results.length} results, #{recent_results.length} of them in the last 24 hours."

Trainer.new(learner, results_model, generator).run

