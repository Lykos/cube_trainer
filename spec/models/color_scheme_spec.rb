# frozen_string_literal: true

require 'rails_helper'
require 'twisty_puzzles'

describe ColorScheme do
  include TwistyPuzzles
  include_context 'with user abc'

  it 'can be constructed from a TwistyPuzzles ColorScheme and back' do
    color_scheme = described_class.from_twisty_puzzles_color_scheme(TwistyPuzzles::ColorScheme::WCA)
    color_scheme.user = user
    expect(color_scheme).to be_valid
    expect(color_scheme.to_twisty_puzzles_color_scheme).to eq(TwistyPuzzles::ColorScheme::WCA)
  end

  describe '#valid?' do
    it 'returns true for valid colors' do
      expect(described_class.new(user: user, color_u: :white, color_f: :green).valid?).to be(true)
    end

    it 'returns false for invalid colors' do
      expect(described_class.new(user: user, color_u: :lol, color_f: :pink).valid?).to be(false)
    end

    it 'returns false for equal colors' do
      expect(described_class.new(user: user, color_u: :green, color_f: :green).valid?).to be(false)
    end

    it 'returns false for opposite colors' do
      expect(described_class.new(user: user, color_u: :green, color_f: :blue).valid?).to be(false)
    end
  end

  describe '#setup' do
    it 'returns an empty algorithm for the WCA color scheme' do
      expect(described_class.new(user: user, color_u: :white, color_f: :green).setup).to be_empty
    end

    context 'when the top color is white' do
      it 'returns y if the front color is red' do
        expect(described_class.new(user: user, color_u: :white, color_f: :red).setup).to eq(parse_algorithm('y'))
      end

      it 'returns y2 if the front color is blue' do
        expect(described_class.new(user: user, color_u: :white, color_f: :blue).setup).to eq(parse_algorithm('y2'))
      end

      it "returns y' if the front color is orange" do
        expect(described_class.new(user: user, color_u: :white, color_f: :orange).setup).to eq(parse_algorithm("y'"))
      end
    end

    context 'when the front is green' do
      it "returns z' if the top color is red" do
        expect(described_class.new(user: user, color_u: :red, color_f: :green).setup).to eq(parse_algorithm("z'"))
      end

      it 'returns z2 if the top color is yellow' do
        expect(described_class.new(user: user, color_u: :yellow, color_f: :green).setup).to eq(parse_algorithm('z2'))
      end

      it 'returns z if the top color is orange' do
        expect(described_class.new(user: user, color_u: :orange, color_f: :green).setup).to eq(parse_algorithm('z'))
      end
    end

    context 'when the top is yellow and the front is green' do
      it 'returns x' do
        setup = described_class.new(user: user, color_u: :yellow, color_f: :red).setup
        solutions =
          [
            'x2 y',
            "z2 y'",
            'y z2'
          ].map { |a| parse_algorithm(a) }
        expect(solutions).to include(setup)
      end
    end
  end
end
