# frozen_string_literal: true

require 'twisty_puzzles'

describe ColorScheme do
  it 'returns the right colors for the Bernhard orientation' do
    expect(ColorScheme::BERNHARD.color(:U)).to be == :yellow
    expect(ColorScheme::BERNHARD.color(:F)).to be == :red
    expect(ColorScheme::BERNHARD.color(:R)).to be == :green
    expect(ColorScheme::BERNHARD.color(:L)).to be == :blue
    expect(ColorScheme::BERNHARD.color(:B)).to be == :orange
    expect(ColorScheme::BERNHARD.color(:D)).to be == :white
  end

  it 'returns the right colors for the WCA orientation' do
    expect(ColorScheme::WCA.color(:U)).to be == :white
    expect(ColorScheme::WCA.color(:F)).to be == :green
    expect(ColorScheme::WCA.color(:R)).to be == :red
    expect(ColorScheme::WCA.color(:L)).to be == :orange
    expect(ColorScheme::WCA.color(:B)).to be == :blue
    expect(ColorScheme::WCA.color(:D)).to be == :yellow
  end
end
