#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/skewb_scrambler'
require 'twisty_puzzles'

SCRAMBLE_LENGTH = 15
SEARCH_DEPTH = 7
MAX_QUEUE_LENGTH = 100

queue = Queue.new

Thread.new do
  layer_finder = CubeTrainer::SkewbLayerFinder.new
  scrambler = CubeTrainer::SkewbScrambler.new
  skewb_state = CubeTrainer::ColorScheme::BERNHARD.solved_skewb_state

  loop do
    scramble = scrambler.random_algorithm(SCRAMBLE_LENGTH)
    queue.push([:scramble, scramble])
    layer_solutions =
      scramble.apply_temporarily_to(skewb_state) do |state|
        layer_finder.find_layer(state, SEARCH_DEPTH)
      end
    queue.push([:solutions, layer_solutions])
    sleep(1) while queue.length > MAX_QUEUE_LENGTH
  end
end

loop do
  type, scramble = queue.pop
  raise unless type == :scramble

  puts 'Scramble'
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
