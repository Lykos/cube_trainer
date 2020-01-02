require 'move'

describe Move do
  it 'should invert M slices correctly' do
    expect(parse_move("M").inverse).to be == parse_move("M'")
    expect(parse_move("M'").inverse).to be == parse_move("M")
    expect(parse_move("S").inverse).to be == parse_move("S'")
    expect(parse_move("S'").inverse).to be == parse_move("S")
    expect(parse_move("E").inverse).to be == parse_move("E'")
    expect(parse_move("E'").inverse).to be == parse_move("E")
  end

  it 'should rotate skewbs correctly' do
    state = SkewbState.solved
    parse_skewb_algorithm("R x F' x'").apply_temporarily_to(state) do
      expect(state).to be == SkewbState.solved
    end
    parse_skewb_algorithm("F y L' y'").apply_temporarily_to(state) do
      expect(state).to be == SkewbState.solved
    end
    parse_skewb_algorithm("B x L' x'").apply_temporarily_to(state) do
      expect(state).to be == SkewbState.solved
    end
  end
end
