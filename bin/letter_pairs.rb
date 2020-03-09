#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/training/letter_pair_word_finder'
require 'cube_trainer/training/dict'

if ARGV.length > 1
  raise 'At most one argument (namely the file to read words from) should be given.'
end

terms =
  if ARGV.empty?
    CubeTrainer::Training::Dict.new.words
  else
    File.readlines(ARGV.first)
  end
finder = CubeTrainer::Training::LetterPairWordFinder.new(terms)

open('/dev/tty') do |f|
  while (letter_sequence = f.gets)
    puts finder.find_term(letter_sequence)
  end
end
