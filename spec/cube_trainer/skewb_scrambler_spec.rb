# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/skewb_scrambler'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe SkewbScrambler do
  let(:scrambler) { SkewbScrambler.new }

  it 'generates scrambles of the right size' do
    property_of do
      Rantly { range(0, 5) }
    end.check do |length|
      expect(scrambler.random_algorithm(length).length).to eq(length)
    end
  end

  it 'generates skewb scrambles' do
    property_of do
      Rantly { range(0, 5) }
    end.check do |length|
      scrambler.random_algorithm(length).moves.each do |move|
        expect(move).to be_a(TwistyPuzzles::SkewbMove)
      end
    end
  end

  it "generates scrambles that can't be trivially reduced" do
    property_of do
      Rantly { range(2, 5) }
    end.check do |length|
      alg = scrambler.random_algorithm(length)
      move_pairs = alg.moves[0..-2].zip(alg.moves[1..])
      move_pairs.each do |first, second|
        expect(first.axis_corner).to_not eq(second.axis_corner)
      end
    end
  end
end
