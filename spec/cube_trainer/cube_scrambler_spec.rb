# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/cube_scrambler'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe CubeScrambler do
  let(:scrambler) { described_class.new }

  it 'generates scrambles of the right size' do
    property_of do
      Rantly { range(0, 5) }
    end.check do |length|
      expect(scrambler.random_algorithm(length).length).to eq(length)
    end
  end

  it 'generates cube scrambles' do
    property_of do
      Rantly { range(0, 5) }
    end.check do |length|
      expect(scrambler.random_algorithm(length).moves).to all(be_a(TwistyPuzzles::CubeMove))
    end
  end

  it "generates scrambles that can't be trivially reduced" do
    property_of do
      Rantly { range(2, 5) }
    end.check do |length|
      alg = scrambler.random_algorithm(length)
      move_pairs = alg.moves[0..-2].zip(alg.moves[1..])
      move_pairs.each do |first, second|
        expect(first.same_axis?(second)).to be(false)
      end
    end
  end
end
