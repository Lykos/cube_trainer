#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/skewb_scrambler'
require 'cube_trainer/skewb_state'
require 'cube_trainer/color_scheme'
require 'cube_trainer/move'

include CubeTrainer

SCRAMBLE_LENGTH = 15
SEARCH_DEPTH = 7

def max_score_after_one_move(skewb_state)
  FixedCornerSkewbMove::ALL.collect do |m|
    SkewbLayerFinder.score_after_move(skewb_state, m)
  end.max
end

def inserting_second_piece_is_not_optimal(skewb_state, layer_solutions)
  if SkewbLayerFinder.layer_score(skewb_state) >= 2
    false
  elsif max_score_after_one_move(skewb_state) < 2
    false
  else
    layer_solutions.extract_algorithms.all? do |_c, as|
      as.all? do |a|
        SkewbLayerFinder.score_after_move(skewb_state, a.moves[0]) < 2
      end
    end
  end
end

def has_desired_property(skewb_state, layer_solutions)
  inserting_second_piece_is_not_optimal(skewb_state, layer_solutions)
end

layer_finder = SkewbLayerFinder.new
scrambler = SkewbScrambler.new
skewb_state = ColorScheme::BERNHARD.solved_skewb_state

loop do
  scramble = scrambler.random_moves(SCRAMBLE_LENGTH)
  layer_solutions = layer_finder.find_layer(skewb_state, SEARCH_DEPTH)
  scramble.apply_to(skewb_state)
  layer_solutions = layer_finder.find_layer(skewb_state, SEARCH_DEPTH)
  if has_desired_property(skewb_state, layer_solutions)
    puts scramble
    puts
    puts skewb_state
    puts
    layer_solutions.extract_algorithms.each do |color, algs|
      puts color
      puts algs
      puts
    end
    break
  end
  scramble.invert.apply_to(skewb_state)
end
