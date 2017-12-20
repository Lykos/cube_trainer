#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'options'
require 'results_model'
require 'ui_helpers'
require 'console_helpers'

include UiHelpers
include ConsoleHelpers

# TODO Do this in the UI.

options = Options.parse(ARGV)
results_model = ResultsModel.new(options.commutator_info.result_symbol)
generator = options.commutator_info.generator_class.new(results_model, options.restrict_letters)

found = results_model.results.collect { |r| r.input }.uniq.length
total = generator.class::VALID_PAIRS.length
missing = total - found
if missing > 0
  puts "#{found} words found, #{missing} missing."
else
  puts "Historic data for all #{total} elements found."
end

loop do
  letter_pair = generator.random_letter_pair
  puts_and_say(letter_pair)
  start = Time.now
  char = wait_for_any_key
  if char.downcase == 'd'
    puts 'Pressed d. Deleting results for the last 10 seconds.'
    results_model.delete_after_time(Time.now - 10)
  else
    time_s = Time.now - start
    puts "Time: #{format_time(time_s)}"
    results_model.record_result(start, time_s, letter_pair)
  end
end
