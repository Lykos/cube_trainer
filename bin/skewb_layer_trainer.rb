#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'move'
require 'skewb_layer_finder'
require 'skewb_scrambler'
require 'skewb_state'
require 'color_scheme'
require 'thread'

include CubeTrainer

SCRAMBLE_LENGTH = 15
SEARCH_DEPTH = 7
MAX_QUEUE_LENGTH = 100

queue = Queue.new

Producer = Thread.new do
  layer_finder = SkewbLayerFinder.new
  scrambler = SkewbScrambler.new
  skewb_state = ColorScheme::BERNHARD.solved_skewb_state

  loop do
    scramble = scrambler.random_moves(SCRAMBLE_LENGTH)
    queue.push([:scramble, scramble])
    scramble.apply_to(skewb_state)
    layer_solutions = layer_finder.find_layer(skewb_state, SEARCH_DEPTH)
    scramble.invert.apply_to(skewb_state)
    queue.push([:solutions, layer_solutions])
    while queue.length > MAX_QUEUE_LENGTH
      sleep(1)
    end
  end
end

loop do
  type, scramble = queue.pop
  raise unless type == :scramble
  puts "Scramble"
  puts scramble
  type, layer_solutions = queue.pop
  puts "#{queue.length / 2} solutions in the queue."
  raise unless type == :solutions
  if layer_solutions.solved?
    puts "Optimal solution has #{layer_solutions.length} moves. Press enter to see solutions."
    gets
    layer_solutions.extract_algorithms.each do |color, algs|
      puts color
      puts algs
      puts
    end
  else
    puts "Couldn't find a solution with the search depth #{SEARCH_DEPTH}."
  end
end
