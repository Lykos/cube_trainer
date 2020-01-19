require 'algorithm'

include CubeTrainer

describe Algorithm do
  it "should invert algorithms correctly" do
    expect(parse_algorithm("R U").inverse).to be == parse_algorithm("U' R'")
  end

  it "should compute the move count of algorithms correctly" do
    algorithm = parse_algorithm("R2 U F' S M2 E'")
    expect(algorithm.move_count).to be == 9
    expect(algorithm.move_count(:htm)).to be == 9
    expect(algorithm.move_count(:qtm)).to be == 12
    expect(algorithm.move_count(:stm)).to be == 6
    expect(algorithm.move_count(:qstm)).to be == 8
    expect(algorithm.move_count(:sqtm)).to be == 8
  end

  it "should compute cancellations of algorithms correctly" do
    # TODO Fix these
    #expect(parse_algorithm("R U").cancellations(parse_algorithm("U' R'"))).to be == 4
    #expect(parse_algorithm("R U2").cancellations(parse_algorithm("U2 R'"))).to be == 4
    expect(parse_algorithm("D U").cancellations(parse_algorithm("D'"))).to be == 2
    #expect(parse_algorithm("D U").cancellations(parse_algorithm("D' U'"))).to be == 2
  end

  it "should apply a rotation correctly to Sarahs skewb algorithm" do
    expect(parse_sarahs_skewb_algorithm("F U R'").rotate(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("L U F'")
    expect(parse_sarahs_skewb_algorithm("L U F'").rotate(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("B U L'")
    expect(parse_sarahs_skewb_algorithm("B U L'").rotate(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("R U B'")
    expect(parse_sarahs_skewb_algorithm("R U B'").rotate(parse_move("y"))).to be == parse_sarahs_skewb_algorithm("F U R'")

    expect(parse_sarahs_skewb_algorithm("F U R'").rotate(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("B U L'")
    expect(parse_sarahs_skewb_algorithm("L U F'").rotate(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("R U B'")
    expect(parse_sarahs_skewb_algorithm("B U L'").rotate(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("F U R'")
    expect(parse_sarahs_skewb_algorithm("R U B'").rotate(parse_move("y2"))).to be == parse_sarahs_skewb_algorithm("L U F'")
    
    expect(parse_sarahs_skewb_algorithm("F U R'").rotate(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("R U B'")
    expect(parse_sarahs_skewb_algorithm("L U F'").rotate(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("F U R'")
    expect(parse_sarahs_skewb_algorithm("B U L'").rotate(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("L U F'")
    expect(parse_sarahs_skewb_algorithm("R U B'").rotate(parse_move("y'"))).to be == parse_sarahs_skewb_algorithm("B U L'")
  end

  it "should mirror Sarahs skewb algorithms correctly" do
    expect(parse_sarahs_skewb_algorithm("F U R'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("L' U B")
    expect(parse_sarahs_skewb_algorithm("L U F'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("F' U L")
    expect(parse_sarahs_skewb_algorithm("B U L'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("R' U F")
    expect(parse_sarahs_skewb_algorithm("R U B'").mirror(Face::F)).to be == parse_sarahs_skewb_algorithm("B' U R")

    expect(parse_sarahs_skewb_algorithm("F U R'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("R' U F")
    expect(parse_sarahs_skewb_algorithm("L U F'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("B' U R")
    expect(parse_sarahs_skewb_algorithm("B U L'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("L' U B")
    expect(parse_sarahs_skewb_algorithm("R U B'").mirror(Face::R)).to be == parse_sarahs_skewb_algorithm("F' U L")
  end
end
