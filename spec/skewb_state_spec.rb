require 'skewb_state'
require 'move'

include CubeTrainer

def parse_skewb_alg(alg_string)
  Algorithm.new(alg_string.split(' ').collect { |move_string| parse_skewb_move(move_string) })
end

describe SkewbState do
  let (:cube_state) { SkewbState.solved }
  
  it 'should have the right solved state' do
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be true
    expect(cube_state.layer_solved?(:red)).to be true
    expect(cube_state.layer_solved?(:green)).to be true
    expect(cube_state.layer_solved?(:blue)).to be true
    expect(cube_state.layer_solved?(:orange)).to be true
    expect(cube_state.layer_solved?(:white)).to be true
    expect(cube_state.to_s).to be == (<<EOS
     YYYYY
     YYYYY
     YYYYY
     YYYYY
     YYYYY
BBBBBRRRRRGGGGGOOOOO
BBBBBRRRRRGGGGGOOOOO
BBBBBRRRRRGGGGGOOOOO
BBBBBRRRRRGGGGGOOOOO
BBBBBRRRRRGGGGGOOOOO
     WWWWW
     WWWWW
     WWWWW
     WWWWW
     WWWWW
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an U move' do
    parse_skewb_move('U').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     GGYYY
     GYYYY
     YYYYY
     YYYYY
     YYYYY
OOOBBRRRRRGGGGGOOWWW
OOOOBRRRRRGGGGGOWWWW
OOOOORRRRRGGGGGWWWWW
OOOOOYRRRRGGGGRWWWWW
OOOOOYYRRRGGGRRWWWWW
     BBBWW
     BBBBW
     BBBBB
     BBBBB
     BBBBB
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an U\' move' do
    parse_skewb_move('U\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     RRYYY
     RYYYY
     YYYYY
     YYYYY
     YYYYY
WWWBBRRRRRGGGGGOOBBB
WWWWBRRRRRGGGGGOBBBB
WWWWWRRRRRGGGGGBBBBB
WWWWWGRRRRGGGGYBBBBB
WWWWWGGRRRGGGYYBBBBB
     OOOWW
     OOOOW
     OOOOO
     OOOOO
     OOOOO
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an R move' do
    parse_skewb_move('R').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     BBBYY
     BBBBY
     BBBBB
     BBBBB
     BBBBB
RRRRRYYYYYOOGGGOOOWW
RRRRRYYYYYOGGGGOOOOW
RRRRRYYYYYGGGGGOOOOO
BRRRRYYYYRGGGGGOOOOO
BBRRRYYYRRGGGGGOOOOO
     GGWWW
     GWWWW
     WWWWW
     WWWWW
     WWWWW
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an R\' move' do
    parse_skewb_move('R\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     RRRYY
     RRRRY
     RRRRR
     RRRRR
     RRRRR
YYYYYBBBBBWWGGGOOOGG
YYYYYBBBBBWGGGGOOOOG
YYYYYBBBBBGGGGGOOOOO
BYYYYBBBBRGGGGGOOOOO
BBYYYBBBRRGGGGGOOOOO
     OOWWW
     OWWWW
     WWWWW
     WWWWW
     WWWWW
EOS
                                            ).chomp
  end
 
  it 'should have the right state after an L move' do
    parse_skewb_move('L').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     GGGGG
     GGGGG
     GGGGG
     YGGGG
     YYGGG
RRBBBRRRWWOOOOOYYYYY
RBBBBRRRRWOOOOOYYYYY
BBBBBRRRRROOOOOYYYYY
BBBBBRRRRRGOOOOYYYYO
BBBBBRRRRRGGOOOYYYOO
     WWWWW
     WWWWW
     WWWWW
     WWWWB
     WWWBB
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an L\' move' do
    parse_skewb_move('L\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     OOOOO
     OOOOO
     OOOOO
     YOOOO
     YYOOO
WWBBBRRRBBYYYYYGGGGG
WBBBBRRRRBYYYYYGGGGG
BBBBBRRRRRYYYYYGGGGG
BBBBBRRRRRGYYYYGGGGO
BBBBBRRRRRGGYYYGGGOO
     WWWWW
     WWWWW
     WWWWW
     WWWWR
     WWWRR
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an B move' do
    parse_skewb_move('B').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     OOOOO
     OOOOO
     OOOOO
     OOOOY
     OOOYY
YYYYYGGRRRGGGWWBBBBB
YYYYYGRRRRGGGGWBBBBB
YYYYYRRRRRGGGGGBBBBB
YYYYBRRRRRGGGGGOBBBB
YYYBBRRRRRGGGGGOOBBB
     WWWWW
     WWWWW
     WWWWW
     RWWWW
     RRWWW
EOS
                                            ).chomp
  end
  
  it 'should have the right state after an B\' move' do
    parse_skewb_move('B\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
    expect(cube_state.to_s).to be == (<<EOS
     BBBBB
     BBBBB
     BBBBB
     BBBBY
     BBBYY
OOOOOWWRRRGGGRRYYYYY
OOOOOWRRRRGGGGRYYYYY
OOOOORRRRRGGGGGYYYYY
OOOOBRRRRRGGGGGOYYYY
OOOBBRRRRRGGGGGOOYYY
     WWWWW
     WWWWW
     WWWWW
     GWWWW
     GGWWW
EOS
                                            ).chomp
  end
  
  it 'should have the red layer solved after a B L\' B\' L sledge' do
    parse_skewb_alg('B L\' B\' L').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be true
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
  end
  
  it 'should have the green layer solved after a U\' B U B\' sledge' do
    parse_skewb_alg('U\' B U B\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be true
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
  end
  
  it 'should have the white layer solved after a R\' B R B\' sledge' do
    parse_skewb_alg('R\' B R B\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be true
  end
  
  it 'should have the blue layer solved after a L\' R B U\' sledge' do
    parse_skewb_alg('L\' R B U\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be true
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
  end
  
  it 'should have the yellow layer solved after a U R\' B\' L sledge' do
    parse_skewb_alg('U R\' B\' L').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be true
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
  end
  
  it 'should have the orange layer solved after a R\' U B L\' sledge' do
    parse_skewb_alg('R\' U B L\'').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be true
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be true
    expect(cube_state.layer_solved?(:white)).to be false
  end
  
  it 'should have no layer solved after a false white layer combo' do
    parse_skewb_alg('R\' L R L\' R\' U\' L U').apply_to(cube_state)
    expect(cube_state.any_layer_solved?).to be false
    expect(cube_state.layer_solved?(:yellow)).to be false
    expect(cube_state.layer_solved?(:red)).to be false
    expect(cube_state.layer_solved?(:green)).to be false
    expect(cube_state.layer_solved?(:blue)).to be false
    expect(cube_state.layer_solved?(:orange)).to be false
    expect(cube_state.layer_solved?(:white)).to be false
  end
end
