require 'move'

describe Move do
  it 'should invert M slices correctly' do
    expect(parse_move('M').invert).to be == parse_move('M\'')
    expect(parse_move('M\'').invert).to be == parse_move('M')
    expect(parse_move('S').invert).to be == parse_move('S\'')
    expect(parse_move('S\'').invert).to be == parse_move('S')
    expect(parse_move('E').invert).to be == parse_move('E\'')
    expect(parse_move('E\'').invert).to be == parse_move('E')
  end
end
