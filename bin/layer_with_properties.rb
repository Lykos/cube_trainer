#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'twisty_puzzles'
require 'cube_trainer/skewb_layer_finder'
require 'cube_trainer/skewb_scrambler'

SCRAMBLE_LENGTH = 15
SEARCH_DEPTH = 7

def score_after_move(layer_finder, skewb_state, move)
  alg = TwistyPuzzles::Algorithm.move(move)
  alg.apply_temporarily_to(skewb_state) { |s| layer_finder.state_score(s) }
end

def max_score_after_one_move(layer_finder, skewb_state)
  TwistyPuzzles::FixedCornerSkewbMove::ALL.map do |m|
    score_after_move(layer_finder, skewb_state, m)
  end.max
end

def inserting_second_piece_is_not_optimal(layer_finder, skewb_state, layer_solutions)
  if layer_finder.state_score(skewb_state) >= 2 || max_score_after_one_move(
    layer_finder,
    skewb_state
  ) < 2
    false
  else
    layer_solutions.extract_algorithms.all? do |_c, as|
      as.all? do |a|
        score_after_move(layer_finder, skewb_state, a.moves[0]) < 2
      end
    end
  end
end

def desired_property?(layer_finder, skewb_state, layer_solutions)
  inserting_second_piece_is_not_optimal(layer_finder, skewb_state, layer_solutions)
end

layer_finder = CubeTrainer::SkewbLayerFinder.new
scrambler = CubeTrainer::SkewbScrambler.new
skewb_state = TwistyPuzzles::ColorScheme::BERNHARD.solved_skewb_state

loop do
  scramble = scrambler.random_moves(SCRAMBLE_LENGTH)
  scramble.apply_temporarily_to(skewb_state) do |state|
    layer_solutions = layer_finder.find_layer(state, SEARCH_DEPTH)
    if desired_property?(layer_finder, state, layer_solutions)
      puts scramble
      puts
      puts state.colored_to_s
      puts
      layer_solutions.extract_algorithms.each do |color, algs|
        puts color
        puts algs
        puts
      end
      break
    end
  end
end
