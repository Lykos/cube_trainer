#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'letters_to_word'
require 'results_model'
require 'ui_helpers'

include UiHelpers

# TODO Do this in the UI.

def display_hints(hints)
  if hints.length < 10
    puts hints
  else
    IO.popen('cat | less', 'w') do |io|
      io.puts(hints)
    end
  end
end

results_model = ResultsModel.new(:letters_to_word)
generator = LettersToWord.new(results_model)

found = results_model.results.length
missing = LettersToWord::VALID_PAIRS.length - found
if missing > 0
  puts "#{found} words found, #{missing} missing."
end

loop do
  letter_pair = generator.random_letter_pair
  puts letter_pair
  start = Time.now
  word = ''
  failed_attempts = -1
  until generator.good_word?(letter_pair, word)
    word = gets.chomp.downcase
    if word == 'hint'
      failed_attempts = 100
      hints = generator.hint(letter_pair)
      display_hints(hints)
      word = ''
    else
      failed_attempts += 1
    end
  end
  time_s = Time.now - start
  puts "Time: #{format_time(time_s)}"
  result = Result.new(start, time_s, letter_pair, failed_attempts, word)
  results_model.record_result(result)
end
