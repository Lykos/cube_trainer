#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'results_model'
require 'ui_helpers'
require 'console_helpers'

include UiHelpers
include ConsoleHelpers

# TODO Do this in the UI.

NUM_COMMS = 1

results_model = ResultsModel.new(:edge_commutators)
generator = EdgeCommutators.new(results_model)

found = results_model.results.length
missing = EdgeCommutators::VALID_PAIRS.length - found
if missing > 0
  puts "#{found} words found, #{missing} missing."
end

loop do
  letter_pairs = NUM_COMMS.times.collect { generator.random_letter_pair }
  edge_memo = letter_pairs.collect { |l| l.to_s }.join(' ')
  puts_and_say(edge_memo)
  start = Time.now
  wait_for_any_key
  time_s = Time.now - start
  puts "Time: #{format_time(time_s)}"
  individual_time = time_s / NUM_COMMS
  letter_pairs.each_with_index do |l, i|
    result = Result.new(start + i * individual_time, individual_time, l, 0, nil)
    results_model.record_result(result)
  end
end
