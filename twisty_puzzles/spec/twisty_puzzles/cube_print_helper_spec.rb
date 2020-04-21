# frozen_string_literal: true

require 'twisty_puzzles/color_scheme'
require 'twisty_puzzles/cube_print_helper'
require 'twisty_puzzles/cube_state'
require 'twisty_puzzles/parser'

def apply_sexy(cube_state)
  parse_algorithm("R U R' U'").apply_to(cube_state)
end

RSpec::Matchers.define(:eq_cube_string) do |expected|
  match do |actual|
    actual.to_s == expected.chomp
  end
  failure_message do |actual|
    "expected that:\n#{actual.colored_to_s}\nwould equal:\n#{expected}"
  end
end

describe CubePrintHelper do
  
  include described_class

  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }

  context 'when the cube size is 2' do
    let(:cube_size) { 2 }

    it 'prints a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expect(cube_state).to eq_cube_string(<<~CUBE)
          YY
          YY
        BBRRGGOO
        BBRRGGOO
          WW
          WW
      CUBE
    end

    it 'prints a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expect(cube_state).to eq_cube_string(<<~CUBE)
          YB
          YR
        OBRWGYOG
        BBRRYGOO
          WG
          WW
      CUBE
    end
  end

  context 'when the cube size is 3' do
    let(:cube_size) { 3 }

    it 'prints a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expect(cube_state).to eq_cube_string(<<~CUBE)
           YYY
           YYY
           YYY
        BBBRRRGGGOOO
        BBBRRRGGGOOO
        BBBRRRGGGOOO
           WWW
           WWW
           WWW
      CUBE
    end

    it 'prints a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expect(cube_state).to eq_cube_string(<<~CUBE)
           YYB
           YYR
           YYR
        OBBRRWGGYOGG
        BBBRRYOGGOOO
        BBBRRRYGGOOO
           WWG
           WWW
           WWW
      CUBE
    end
  end

  context 'when the cube size is 4' do
    let(:cube_size) { 4 }

    it 'prints a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expect(cube_state).to eq_cube_string(<<~CUBE)
            YYYY
            YYYY
            YYYY
            YYYY
        BBBBRRRRGGGGOOOO
        BBBBRRRRGGGGOOOO
        BBBBRRRRGGGGOOOO
        BBBBRRRRGGGGOOOO
            WWWW
            WWWW
            WWWW
            WWWW
      CUBE
    end

    it 'prints a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expect(cube_state).to eq_cube_string(<<~CUBE)
            YYYB
            YYYR
            YYYR
            YYYR
        OBBBRRRWGGGYOGGG
        BBBBRRRYOGGGOOOO
        BBBBRRRYOGGGOOOO
        BBBBRRRRYGGGOOOO
            WWWG
            WWWW
            WWWW
            WWWW
      CUBE
    end
  end
end
