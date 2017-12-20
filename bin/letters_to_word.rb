#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'letters_to_word'
require 'results_model'
require 'ui_helpers'
require 'console_helpers'

include UiHelpers
include ConsoleHelpers

# TODO Do this in the UI.

def display_hints(hints)
  if hints.length < 10
    puts_and_say(hints)
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
  puts_and_say(letter_pair)
  start = Time.now
  word = ''
  failed_attempts = -1
  replaced = false
  until generator.good_word?(letter_pair, word)
    if word != '' && word != 'hint'
      if !letter_pair.matches_word?(word)
        puts_and_say('Bad word!', 'en')
      else
        puts_and_say('Incorrect!', 'en')
      end
    end
    last_word = word
    word = gets.chomp.downcase
    if word == 'hint'
      failed_attempts = 100
      hints = generator.hint(letter_pair)
      display_hints(hints)
      word = ''
    elsif last_word != '' && word == 'replace'
      if letter_pair.matches_word?(last_word)
        results_model.replace_word(letter_pair, last_word)
        replaced = true
      else
        puts_and_say('Cannot replace word with an invalid word.', 'en')
      end
    else
      failed_attempts += 1
    end
  end
  next if replaced
  time_s = Time.now - start
  puts "Time: #{format_time(time_s)}"
  results_model.record_result(start, time_s, letter_pair, failed_attempts, word)
end
