#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/letter_pair_word_finder'
require 'cube_trainer/dict'

include CubeTrainer

if ARGV.length > 1
  raise 'At most one argument (namely the file to read words from) should be given.'
end

terms = if ARGV.empty?
          Dict.new.words
        else
          File.readlines(ARGV.first)
        end
finder = LetterPairWordFinder.new(terms)

open('/dev/tty') do |f|
  while letter_sequence = f.gets
    puts finder.find_term(letter_sequence)
  end
end
