require 'cube_trainer/cube_print_helper'
require 'cube_trainer/cube_state'
require 'cube_trainer/color_scheme'
require 'cube_trainer/parser'

include CubeTrainer

def apply_sexy(cube_state)
  cube_state.apply_move(parse_move('R'))
  cube_state.apply_move(parse_move('U'))
  cube_state.apply_move(parse_move('R\''))
  cube_state.apply_move(parse_move('U\''))
end

describe CubePrintHelper do

  include CubePrintHelper

  let(:color_scheme) { ColorScheme::BERNHARD }

  context 'when the cube size is 2' do
    let(:cube_size) { 2 }
    
    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<EOS
  YY
  YY
BBRRGGOO
BBRRGGOO
  WW
  WW
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      puts
      puts cube_string(cube_state, :color)
      expected = <<EOS
  YB
  YR
OBRWGYOG
BBRRYGOO
  WG
  WW
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end

  end

  context 'when the cube size is 3' do
    let(:cube_size) { 3 }
    
    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<EOS
   YYY
   YYY
   YYY
BBBRRRGGGOOO
BBBRRRGGGOOO
BBBRRRGGGOOO
   WWW
   WWW
   WWW
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expected = <<EOS
   YYB
   YYR
   YYR
OBBRRWGGYOGG
BBBRRYOGGOOO
BBBRRRYGGOOO
   WWG
   WWW
   WWW
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end
  end

  context 'when the cube size is 4' do
    let(:cube_size) { 4 }
    
    it 'should print a solved state correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      expected = <<EOS
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
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end

    it 'should print a state after sexy move correctly' do
      cube_state = color_scheme.solved_cube_state(cube_size)
      apply_sexy(cube_state)
      expected = <<EOS
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
EOS
      expect(cube_state.to_s).to be == expected.chomp
    end
  end

end
