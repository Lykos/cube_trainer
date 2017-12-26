#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'options'
require 'results_model'
require 'ui_helpers'
require 'console_helpers'
require 'input_sampler'

include UiHelpers
include ConsoleHelpers

# TODO Do this in the UI.

options = Options.parse(ARGV)
results_model = ResultsModel.new(options.commutator_info.result_symbol)
generator = options.commutator_info.generator_class.new(results_model, options.restrict_letters)

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

loop do
  letter_pair = generator.random_letter_pair
  puts_and_say(letter_pair)
  data = time_before_any_key_press(generator.hint(letter_pair))
  if data.char == 'd'
    puts 'Pressed d. Deleting results for the last 10 seconds.'
    results_model.delete_after_time(Time.now - 10)
  else
    puts "Time: #{format_time(data.time_s)}"
    results_model.record_result(data.start, data.time_s, letter_pair)
  end
end
