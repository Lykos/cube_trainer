#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'commutators'
require 'results_model'
require 'ui_helpers'

include UiHelpers

# TODO Do this in the UI.

def puts_and_say(stuff)
  puts stuff
  system("echo '#{stuff}' | espeak -v de -s 120")
end

results_model = ResultsModel.new(:letters_to_word)
generator = CornerCommutators.new(results_model)

loop do
  letter_pair = generator.random_letter_pair
  puts_and_say(letter_pair)
  start = Time.now
  gets.chomp
  time_s = Time.now - start
  puts "Time: #{format_time(time_s)}"
  result = Result.new(start, time_s, letter_pair, 0, nil)
  results_model.record_result(result)
end
