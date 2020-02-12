# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/core/skewb_state'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/cube_print_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

include CubeTrainer
include CubePrintHelper

describe SkewbState do
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:skewb_state) { color_scheme.solved_skewb_state }

  it 'should not be equal to a state with one sticker changed' do
    property_of do
      Rantly { skewb_coordinate }
    end.check do |c|
      other_skewb_state = skewb_state.dup
      other_skewb_state[c] = :other_color
      expect(other_skewb_state == skewb_state).to be_falsey
    end
  end

  it 'should have the right solved state' do
    expect(skewb_state.any_layer_solved?).to be true
    expect(skewb_state.solved_layers).to be == %i[yellow red green blue orange white]
    expect(skewb_state.layer_solved?(:yellow)).to be true
    expect(skewb_state.layer_solved?(:red)).to be true
    expect(skewb_state.layer_solved?(:green)).to be true
    expect(skewb_state.layer_solved?(:blue)).to be true
    expect(skewb_state.layer_solved?(:orange)).to be true
    expect(skewb_state.layer_solved?(:white)).to be true
    expect(skewb_state.to_s).to be == <<~EOS
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
                                      .chomp
  end

  context 'when using fixed corner notation' do
    it 'should have the right state after an U move' do
      parse_fixed_corner_skewb_algorithm('U').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
    end

    it "should have the right state after an U' move" do
      parse_fixed_corner_skewb_algorithm("U'").apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it 'should have the right state after an R move' do
      parse_fixed_corner_skewb_algorithm('R').apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
             YYYRR
             YYYYR
             YYYYY
             YYYYY
             YYYYY
        BBBBBRRRRRGGWWWGGGOO
        BBBBBRRRRRGWWWWGGGGO
        BBBBBRRRRRWWWWWGGGGG
        YBBBBRRRRBWWWWWGGGGG
        YYBBBRRRBBWWWWWGGGGG
             WWOOO
             WOOOO
             OOOOO
             OOOOO
             OOOOO
      EOS
                                        .chomp
    end

    it "should have the right state after an R' move" do
      parse_fixed_corner_skewb_algorithm("R'").apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
             YYYBB
             YYYYB
             YYYYY
             YYYYY
             YYYYY
        BBBBBRRRRRGGOOOWWWOO
        BBBBBRRRRRGOOOOWWWWO
        BBBBBRRRRROOOOOWWWWW
        RBBBBRRRRYOOOOOWWWWW
        RRBBBRRRYYOOOOOWWWWW
             WWGGG
             WGGGG
             GGGGG
             GGGGG
             GGGGG
      EOS
                                        .chomp
    end

    it 'should have the right state after an L move' do
      parse_fixed_corner_skewb_algorithm('L').apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
             YYYYY
             YYYYY
             YYYYY
             OYYYY
             OOYYY
        BBWWWBBBRRGGGGGOOOOO
        BWWWWBBBBRGGGGGOOOOO
        WWWWWBBBBBGGGGGOOOOO
        WWWWWBBBBBYGGGGOOOOG
        WWWWWBBBBBYYGGGOOOGG
             RRRRR
             RRRRR
             RRRRR
             RRRRW
             RRRWW
      EOS
                                        .chomp
    end

    it "should have the right state after an L' move" do
      parse_fixed_corner_skewb_algorithm("L'").apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
             YYYYY
             YYYYY
             YYYYY
             GYYYY
             GGYYY
        BBRRRWWWRRGGGGGOOOOO
        BRRRRWWWWRGGGGGOOOOO
        RRRRRWWWWWGGGGGOOOOO
        RRRRRWWWWWOGGGGOOOOY
        RRRRRWWWWWOOGGGOOOYY
             BBBBB
             BBBBB
             BBBBB
             BBBBW
             BBBWW
      EOS
                                        .chomp
    end

    it 'should have the right state after an B move' do
      parse_fixed_corner_skewb_algorithm('B').apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it "should have the right state after an B' move" do
      parse_fixed_corner_skewb_algorithm("B'").apply_to(skewb_state)
      expect(skewb_state.any_layer_solved?).to be false
      expect(skewb_state.layer_solved?(:yellow)).to be false
      expect(skewb_state.layer_solved?(:red)).to be false
      expect(skewb_state.layer_solved?(:green)).to be false
      expect(skewb_state.layer_solved?(:blue)).to be false
      expect(skewb_state.layer_solved?(:orange)).to be false
      expect(skewb_state.layer_solved?(:white)).to be false
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it 'should have the right state after an x rotation' do
      parse_fixed_corner_skewb_algorithm('x').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             RRRRR
             RRRRR
             RRRRR
             RRRRR
             RRRRR
        BBBBBWWWWWGGGGGYYYYY
        BBBBBWWWWWGGGGGYYYYY
        BBBBBWWWWWGGGGGYYYYY
        BBBBBWWWWWGGGGGYYYYY
        BBBBBWWWWWGGGGGYYYYY
             OOOOO
             OOOOO
             OOOOO
             OOOOO
             OOOOO
      EOS
                                        .chomp
    end

    it 'should have the right state after an y rotation' do
      parse_fixed_corner_skewb_algorithm('y').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYYYY
             YYYYY
             YYYYY
             YYYYY
             YYYYY
        RRRRRGGGGGOOOOOBBBBB
        RRRRRGGGGGOOOOOBBBBB
        RRRRRGGGGGOOOOOBBBBB
        RRRRRGGGGGOOOOOBBBBB
        RRRRRGGGGGOOOOOBBBBB
             WWWWW
             WWWWW
             WWWWW
             WWWWW
             WWWWW
      EOS
                                        .chomp
    end

    it 'should have the right state after an z rotation' do
      parse_fixed_corner_skewb_algorithm('z').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             BBBBB
             BBBBB
             BBBBB
             BBBBB
             BBBBB
        WWWWWRRRRRYYYYYOOOOO
        WWWWWRRRRRYYYYYOOOOO
        WWWWWRRRRRYYYYYOOOOO
        WWWWWRRRRRYYYYYOOOOO
        WWWWWRRRRRYYYYYOOOOO
             GGGGG
             GGGGG
             GGGGG
             GGGGG
             GGGGG
      EOS
                                        .chomp
    end

    context 'when using WCA orientation' do
      let(:color_scheme) { ColorScheme::WCA }

      it "should have the red layer solved after a B L' B' L sledge" do
        parse_fixed_corner_skewb_algorithm("B L' B' L").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be true
        expect(skewb_state.solved_layers).to be == [:red]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be true
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
      end

      it "should have the green layer solved after a U' B U B' sledge" do
        parse_fixed_corner_skewb_algorithm("U' B U B'").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be true
        expect(skewb_state.solved_layers).to be == [:green]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be true
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
      end

      it "should have the white layer solved after a R' B R B' sledge" do
        parse_fixed_corner_skewb_algorithm("R' B R B'").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be true
        expect(skewb_state.solved_layers).to be == [:white]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be true
      end

      it "should have the blue layer solved after a L' R B U' sledge" do
        parse_fixed_corner_skewb_algorithm("L' R B U'").apply_to(skewb_state)
        expect(skewb_state.solved_layers).to be == [:blue]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be true
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
        expect(skewb_state.any_layer_solved?).to be true
      end

      it "should have the orange layer solved after a R L' B' U sledge" do
        parse_fixed_corner_skewb_algorithm("R L' B' U").apply_to(skewb_state)
        expect(skewb_state.solved_layers).to be == [:orange]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be true
        expect(skewb_state.layer_solved?(:white)).to be false
        expect(skewb_state.any_layer_solved?).to be true
      end

      it "should have the yellow layer solved after a U R' B' L sledge" do
        parse_fixed_corner_skewb_algorithm("U R' B' L").apply_to(skewb_state)
        expect(skewb_state.solved_layers).to be == [:yellow]
        expect(skewb_state.layer_solved?(:yellow)).to be true
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
        expect(skewb_state.any_layer_solved?).to be true
      end

      it "should have the orange layer solved after a R' U B L' sledge" do
        parse_fixed_corner_skewb_algorithm("R' U B L'").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be true
        expect(skewb_state.solved_layers).to be == [:orange]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be true
        expect(skewb_state.layer_solved?(:white)).to be false
      end

      it "should have the blue layer solved after a L U' B' R sledge" do
        parse_fixed_corner_skewb_algorithm("L U' B' R").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be true
        expect(skewb_state.solved_layers).to be == [:blue]
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be true
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
      end

      it 'should have no layer solved after a false white layer combo' do
        parse_fixed_corner_skewb_algorithm("R' L R L' R' U' L U").apply_to(skewb_state)
        expect(skewb_state.any_layer_solved?).to be false
        expect(skewb_state.layer_solved?(:yellow)).to be false
        expect(skewb_state.layer_solved?(:red)).to be false
        expect(skewb_state.layer_solved?(:green)).to be false
        expect(skewb_state.layer_solved?(:blue)).to be false
        expect(skewb_state.layer_solved?(:orange)).to be false
        expect(skewb_state.layer_solved?(:white)).to be false
      end
    end
  end

  context "when using Sarah's notation" do
    it 'should have the right state after an F move' do
      parse_sarahs_skewb_algorithm('F').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYRRR
             YRRRR
             RRRRR
             RRRRR
             RRRRR
        BBBWWGGGGGYYYYYBBOOO
        BBBBWGGGGGYYYYYBOOOO
        BBBBBGGGGGYYYYYOOOOO
        BBBBBRGGGGYYYYGOOOOO
        BBBBBRRGGGYYYGGOOOOO
             WWWOO
             WWWWO
             WWWWW
             WWWWW
             WWWWW
      EOS
                                        .chomp
    end

    it "should have the right state after an F' move" do
      parse_sarahs_skewb_algorithm("F'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYGGG
             YGGGG
             GGGGG
             GGGGG
             GGGGG
        BBBOOYYYYYRRRRRWWOOO
        BBBBOYYYYYRRRRRWOOOO
        BBBBBYYYYYRRRRROOOOO
        BBBBBRYYYYRRRRGOOOOO
        BBBBBRRYYYRRRGGOOOOO
             WWWBB
             WWWWB
             WWWWW
             WWWWW
             WWWWW
      EOS
                                        .chomp
    end

    it 'should have the right state after an R move' do
      parse_sarahs_skewb_algorithm('R').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it "should have the right state after an R' move" do
      parse_sarahs_skewb_algorithm("R'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it 'should have the right state after an L move' do
      parse_sarahs_skewb_algorithm('L').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it "should have the right state after an L' move" do
      parse_sarahs_skewb_algorithm("L'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it 'should have the right state after an B move' do
      parse_sarahs_skewb_algorithm('B').apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it "should have the right state after an B' move" do
      parse_sarahs_skewb_algorithm("B'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
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
                                        .chomp
    end

    it "should have the right state after an F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' B").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             OOOOO
             OOOOO
             OOOOO
             WOOOG
             WWOGG
        YYGGGRRYYYRRRWWBBBBB
        YGGGGRYYYYRRRRWBBBBB
        GGGGGYYYYYRRRRRBBBBB
        GGGGBRYYYYRRRRGOBBBO
        GGGBBRRYYYRRRGGOOBOO
             WWWBB
             WWWWB
             WWWWW
             YWWWW
             YYWWW
      EOS
                                        .chomp
    end

    it "should have the right state after an R' F' algorithm" do
      parse_sarahs_skewb_algorithm("R' F'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             OOYGG
             OYYYG
             YYYYY
             YYYYY
             YYYYY
        WWBGGOOOOOBBRRRWWGGG
        WBBBGOOOOOBRRRRWGGGG
        BBBBBOOOOORRRRRGGGGG
        BBBBBROOOYRRRRYGGGGO
        BBBBBRROYYRRRYYGGGOO
             WWWBB
             WWWWB
             WWWWW
             WWWWR
             WWWRR
      EOS
                                        .chomp
    end

    it "should have the right state after an R' F' x algorithm" do
      parse_sarahs_skewb_algorithm("R' F' x").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             OOOOO
             OOOOO
             OOOOO
             ROOOY
             RROYY
        GGBBBWWWBBRRRBBYYYYY
        GBBBBWWWWBRRRRBYYYYY
        BBBBBWWWWWRRRRRYYYYY
        WBBBBWWWWRYRRRRGYYYO
        WWBBBWWWRRYYRRRGGYOO
             OOGGG
             OGGGG
             GGGGG
             GGGGW
             GGGWW
      EOS
                                        .chomp
    end

    it "should have the right state after an R' F' y2 algorithm" do
      parse_sarahs_skewb_algorithm("R' F' y2").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYYYY
             YYYYY
             YYYYY
             GYYYO
             GGYOO
        BBRRRWWGGGWWBGGOOOOO
        BRRRRWGGGGWBBBGOOOOO
        RRRRRGGGGGBBBBBOOOOO
        RRRRYGGGGOBBBBBROOOY
        RRRYYGGGOOBBBBBRROYY
             RRWWW
             RWWWW
             WWWWW
             BWWWW
             BBWWW
      EOS
                                        .chomp
    end

    it "should have the right state after an R' F' z' algorithm" do
      parse_sarahs_skewb_algorithm("R' F' z'").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             RRRYY
             RRRRY
             RRRRR
             BRRRR
             BBRRR
        GGYYYOOOYYBBWRRGGGWW
        GYYYYOOOOYBWWWRGGGGW
        YYYYYOOOOOWWWWWGGGGG
        OYYYYOOOORWWWWWOGGGG
        OOYYYOOORRWWWWWOOGGG
             GGBBB
             GBBBB
             BBBBB
             WBBBB
             WWBBB
      EOS
                                        .chomp
    end

    it "should have the right state after an F' R' F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' R' F' B").apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             GGROO
             GRRRO
             RRRRR
             BRRRY
             BBRYY
        OOGRRYYOOOBBYWWBBBWW
        OGGGRYOOOOBYYYWBBBBW
        GGGGGOOOOOYYYYYBBBBB
        GGGGBROOOGYYYYGRBBBR
        GGGBBRROGGYYYGGRRBRR
             WWWOO
             WWWWO
             WWWWW
             WWWWY
             WWWYY
      EOS
                                        .chomp
    end

    it "should have the right state after an F' R' + F' B algorithm" do
      first_algorithm = parse_sarahs_skewb_algorithm("F' R'")
      second_algorithm = parse_sarahs_skewb_algorithm("F' B")
      algorithm = first_algorithm.compiled_for_skewb + second_algorithm.compiled_for_skewb
      algorithm.apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             GGROO
             GRRRO
             RRRRR
             BRRRY
             BBRYY
        OOGRRYYOOOBBYWWBBBWW
        OGGGRYOOOOBYYYWBBBBW
        GGGGGOOOOOYYYYYBBBBB
        GGGGBROOOGYYYYGRBBBR
        GGGBBRROGGYYYGGRRBRR
             WWWOO
             WWWWO
             WWWWW
             WWWWY
             WWWYY
      EOS
                                        .chomp
    end

    it "should have the right state after a F' R' F' B algorithm mirrored along the F normal" do
      parse_sarahs_skewb_algorithm("F' R' F' B").compiled_for_skewb.mirror(Face::F).apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             BBOYY
             BOOOY
             OOOOO
             GOOOR
             GGORR
        OOGRRWWBBBWWYBBRRRYY
        OGGGRWBBBBWYYYBRRRRY
        GGGGGBBBBBYYYYYRRRRR
        BGGGGOBBBOGYYYYGRRRO
        BBGGGOOBOOGGYYYGGROO
             WWWYY
             WWWWY
             WWWWW
             WWWWR
             WWWRR
      EOS
                                        .chomp
    end

    it "should have the right state after an inverted F' R' F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' R' F' B").compiled_for_skewb.inverse.apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYGGG
             YGGGG
             GGGGG
             RGGGW
             RRGWW
        GGOYYBBYOOGGBRRWWRRR
        GOOOYBYYYOGBBBRWRRRR
        OOOOOYYYYYBBBBBRRRRR
        OOOOBRYYYOBBBBYBRRRY
        OOOBBRRYOOBBBYYBBRYY
             WWWWW
             WWWWW
             WWWWW
             GWWWO
             GGWOO
      EOS
                                        .chomp
    end

    it "should have the right state after a x rotated F' R' F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' R' F' B").compiled_for_skewb.rotate_by(parse_move('x')).apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             OOWWW
             OWWWW
             WWWWW
             YWWWG
             YYWGG
        YYGBBRRRWWOOOBBOOYBB
        YGGGBRRRRWOOOOBOYYYB
        GGGGGRRRRROOOOOYYYYY
        WGGGGRRRROGOOORWYYYG
        WWGGGRRROOGGORRWWYGG
             YYBYY
             YBBBY
             BBBBB
             RBBBB
             RRBBB
      EOS
                                        .chomp
    end

    it "should have the right state after a y2 rotated F' R' F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' R' F' B").compiled_for_skewb.rotate_by(parse_move('y2')).apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             YYOGG
             YOOOG
             OOOOO
             ROOOB
             RROBB
        GGYWWGGGWWRRBOOYYRRR
        GYYYWGGGGWRBBBOYRRRR
        YYYYYGGGGGBBBBBRRRRR
        YYYYBOGGGOBBBBGORRRB
        YYYBBOOGOOBBBGGOORBB
             YYWWW
             YWWWW
             WWWWW
             RWWWW
             RRWWW
      EOS
                                        .chomp
    end

    it "should have the right state after a z' rotated F' R' F' B algorithm" do
      parse_sarahs_skewb_algorithm("F' R' F' B").compiled_for_skewb.rotate_by(parse_move("z'")).apply_to(skewb_state)
      expect(skewb_state.to_s).to be == <<~EOS
             GGBYY
             GBBBY
             BBBBB
             WBBBB
             WWBBB
        OORBBOOOYYOOGBBRRWWW
        ORRRBOOOOYOGGGBRWWWW
        RRRRROOOOOGGGGGWWWWW
        YRRRWBOOORGGGGGRWWWG
        YYRWWBBORRGGGGGRRWGG
             RRYWW
             RYYYW
             YYYYY
             OYYYY
             OOYYY
      EOS
                                        .chomp
    end
  end
end
