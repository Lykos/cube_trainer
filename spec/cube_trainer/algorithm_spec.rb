require 'cube_trainer/algorithm'
require 'cube_trainer/parser'

describe Algorithm do
  let (:cube_size) { 3 }
  
  it "should invert algorithms correctly" do
    expect(parse_algorithm("R U").inverse).to be == parse_algorithm("U' R'")
  end

  it "should compute the move count of algorithms correctly" do
    algorithm = parse_algorithm("R2 U F' S M2 E'")
    expect(algorithm.move_count(cube_size)).to be == 9
    expect(algorithm.move_count(cube_size, :htm)).to be == 9
    expect(algorithm.move_count(cube_size, :qtm)).to be == 12
    expect(algorithm.move_count(cube_size, :stm)).to be == 6
    expect(algorithm.move_count(cube_size, :qstm)).to be == 8
    expect(algorithm.move_count(cube_size, :sqtm)).to be == 8
  end

  it "should compute cancellations of single moves correctly" do
    expect(parse_algorithm("R2").cancellations(parse_algorithm("R2"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("R'"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("R"), cube_size)).to be == 1
    expect(parse_algorithm("R").cancellations(parse_algorithm("R2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("R2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("R'"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("R"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("R'"), cube_size)).to be == 1
  end
  
  it "should compute cancellations of single wide moves correctly" do
    expect(parse_algorithm("R").cancellations(parse_algorithm("l"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("l2"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("l'"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("l2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("l2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("l'"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("l"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("l'"), cube_size)).to be == 1
  end
  
  it "should compute cancellations of single M moves correctly" do
    expect(parse_algorithm("R2").cancellations(parse_algorithm("M2"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("M'"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("M"), cube_size)).to be == 0
    expect(parse_algorithm("R").cancellations(parse_algorithm("M2"), cube_size)).to be == 0
    expect(parse_algorithm("R'").cancellations(parse_algorithm("M2"), cube_size)).to be == 0
    expect(parse_algorithm("R'").cancellations(parse_algorithm("M'"), cube_size)).to be == 0
    expect(parse_algorithm("R2").cancellations(parse_algorithm("M"), cube_size)).to be == 0
    expect(parse_algorithm("R2").cancellations(parse_algorithm("M'"), cube_size)).to be == 0
  end
  
  it "should compute cancellations of moves across easy rotations correctly" do
    expect(parse_algorithm("R2").cancellations(parse_algorithm("x R2"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("x' R'"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("x R"), cube_size)).to be == 1
    expect(parse_algorithm("R").cancellations(parse_algorithm("x R2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("x' R2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("x R'"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("x R"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("x R'"), cube_size)).to be == 1
  end

  it "should compute cancellations of moves across hard rotations correctly" do
    expect(parse_algorithm("R2").cancellations(parse_algorithm("y F2"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("y F'"), cube_size)).to be == 2
    expect(parse_algorithm("R").cancellations(parse_algorithm("y F"), cube_size)).to be == 1
    expect(parse_algorithm("R").cancellations(parse_algorithm("y F2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("y' B2"), cube_size)).to be == 1
    expect(parse_algorithm("R'").cancellations(parse_algorithm("y' B'"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("y' B"), cube_size)).to be == 1
    expect(parse_algorithm("R2").cancellations(parse_algorithm("y' B'"), cube_size)).to be == 1
  end
  
  it "should compute cancellations of algorithms correctly" do
    expect(parse_algorithm("R U").cancellations(parse_algorithm("U' R'"), cube_size)).to be == 4
    expect(parse_algorithm("R U").cancellations(parse_algorithm("U' R"), cube_size)).to be == 3
    expect(parse_algorithm("R U").cancellations(parse_algorithm("U R'"), cube_size)).to be == 1
    expect(parse_algorithm("R U2").cancellations(parse_algorithm("U2 R'"), cube_size)).to be == 4
  end

  it "should compute cancellations of cancelling algorithms correctly" do
    expect(parse_algorithm("R R U").cancellations(parse_algorithm("U U2 R' R'"), cube_size)).to be == 4
  end

  it "should compute cancellations of algorithms correctly if stuff has to be swapped around" do
    expect(parse_algorithm("D U").cancellations(parse_algorithm("D'"), cube_size)).to be == 2
    expect(parse_algorithm("D U").cancellations(parse_algorithm("D' U'"), cube_size)).to be == 4
    expect(parse_algorithm("D U R'").cancellations(parse_algorithm("R D' U'"), cube_size)).to be == 6
    expect(parse_algorithm("D U R' L").cancellations(parse_algorithm("R L' D' U'"), cube_size)).to be == 8
  end

  it "should compute cancellations of algorithms across easy rotations correctly" do
    expect(parse_algorithm("R x U y L").cancellations(parse_algorithm("z U' R F"), cube_size)).to be == 3
  end
  
  it "should apply a rotation correctly to Sarahs skewb algorithm" do
    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("F R'")

    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("B L'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("L F'")
    
    expect(parse_sarahs_skewb_algorithm("F R'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("R B'")
    expect(parse_sarahs_skewb_algorithm("L F'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("F R'")
    expect(parse_sarahs_skewb_algorithm("B L'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("L F'")
    expect(parse_sarahs_skewb_algorithm("R B'").rotate_by(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("B L'")
  end

  it "should mirror Sarahs skewb algorithms correctly" do
    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("F' L")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("B' R")

    expect(parse_sarahs_skewb_algorithm("F R'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("R' F")
    expect(parse_sarahs_skewb_algorithm("L F'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("B' R")
    expect(parse_sarahs_skewb_algorithm("B L'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("L' B")
    expect(parse_sarahs_skewb_algorithm("R B'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("F' L")
  end
end
