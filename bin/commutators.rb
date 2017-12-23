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
  data = time_before_any_key_press(generator.hint(letter_pair))
  if data.char == 'd'
    puts 'Pressed d. Deleting results for the last 10 seconds.'
    results_model.delete_after_time(Time.now - 10)
  else
    puts "Time: #{format_time(data.time_s)}"
    results_model.record_result(data.start, data.time_s, letter_pair)
  end
end
