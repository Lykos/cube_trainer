require 'algorithm'

include CubeTrainer

describe Algorithm do
  it 'should invert algorithms correctly' do
    expect(parse_algorithm('R U').invert).to be == parse_algorithm('U\' R\'')
  end

  it 'should compute the move count of algorithms correctly' do
    algorithm = parse_algorithm('R2 U F\' S M2 E\'')
    expect(algorithm.move_count).to be 9
    expect(algorithm.move_count(:htm)).to be 9
    expect(algorithm.move_count(:qtm)).to be 12
    expect(algorithm.move_count(:stm)).to be 6
    expect(algorithm.move_count(:qstm)).to be 8
    expect(algorithm.move_count(:sqtm)).to be 8
  end
end
