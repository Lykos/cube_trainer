# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/core/cube_state'
require 'cube_trainer/core/parser'

def apply_sexy(cube_state)
  parse_algorithm("R U R' U'").apply_to(cube_state)
end

describe Core::CubePrintHelper do
  include Core::CubePrintHelper

  let(:color_scheme) { ColorScheme::BERNHARD }

  context 'when the cube size is 2' do
    let(:cube_size) { 2 }

    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<~CUBE.chomp
          YY
          YY
        BBRRGGOO
        BBRRGGOO
          WW
          WW
      CUBE
      expect(cube_state.to_s).to be == expected
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expected = <<~CUBE.chomp
          YB
          YR
        OBRWGYOG
        BBRRYGOO
          WG
          WW
      CUBE
      expect(cube_state.to_s).to be == expected
    end
  end

  context 'when the cube size is 3' do
    let(:cube_size) { 3 }

    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<~CUBE.chomp
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
      expect(cube_state.to_s).to be == expected
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expected = <<~CUBE.chomp
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
      expect(cube_state.to_s).to be == expected
    end
  end

  context 'when the cube size is 4' do
    let(:cube_size) { 4 }

    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<~CUBE.chomp
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
      expect(cube_state.to_s).to be == expected
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expected = <<~CUBE.chomp
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
      expect(cube_state.to_s).to be == expected
    end
  end
end
