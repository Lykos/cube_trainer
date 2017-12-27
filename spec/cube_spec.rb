require 'cube'

RSpec.shared_examples 'Part' do |clazz|
  let(:letter) { ALPHABET.sample }
  
  it 'should find the piece with the right letter' do
    expect(clazz.for_letter(letter).letter).to be == letter
  end
end

describe Edge do
  it_behaves_like 'Part', Edge
end

describe Midge do
  it_behaves_like 'Part', Midge
end

describe Wing do
  it_behaves_like 'Part', Wing

  it 'should parse wings in UB correctly' do
    expect(Wing.parse('UBl')).to be == Wing.new([:orange, :yellow])
    expect(Wing.parse('UBr')).to be == Wing.new([:yellow, :orange])
    expect(Wing.parse('BUl')).to be == Wing.new([:orange, :yellow])
    expect(Wing.parse('BUr')).to be == Wing.new([:yellow, :orange])
  end

  it 'should parse wings in DB correctly' do
    expect(Wing.parse('DBL')).to be == Wing.new([:white, :orange])
    expect(Wing.parse('DBR')).to be == Wing.new([:orange, :white])
    expect(Wing.parse('BDL')).to be == Wing.new([:white, :orange])
    expect(Wing.parse('BDR')).to be == Wing.new([:orange, :white])
  end

  it 'should parse wings in UF correctly' do
    expect(Wing.parse('UFl')).to be == Wing.new([:yellow, :red])
    expect(Wing.parse('UFr')).to be == Wing.new([:red, :yellow])
    expect(Wing.parse('FUl')).to be == Wing.new([:yellow, :red])
    expect(Wing.parse('FUr')).to be == Wing.new([:red, :yellow])
  end

  it 'should parse wings in DF correctly' do
    expect(Wing.parse('DFl')).to be == Wing.new([:red, :white])
    expect(Wing.parse('DFr')).to be == Wing.new([:white, :red])
    expect(Wing.parse('FDl')).to be == Wing.new([:red, :white])
    expect(Wing.parse('FDr')).to be == Wing.new([:white, :red])
  end

  it 'should parse wings in UR correctly' do
    expect(Wing.parse('URb')).to be == Wing.new([:green, :yellow])
    expect(Wing.parse('URf')).to be == Wing.new([:yellow, :green])
    expect(Wing.parse('RUb')).to be == Wing.new([:green, :yellow])
    expect(Wing.parse('RUf')).to be == Wing.new([:yellow, :green])
  end

  it 'should parse wings in FR correctly' do
    expect(Wing.parse('FRu')).to be == Wing.new([:green, :red])
    expect(Wing.parse('FRd')).to be == Wing.new([:red, :green])
    expect(Wing.parse('RFu')).to be == Wing.new([:green, :red])
    expect(Wing.parse('RFd')).to be == Wing.new([:red, :green])
  end
end

describe Corner do
  it_behaves_like 'Part', Corner
end

describe TCenter do
  it_behaves_like 'Part', TCenter
end

describe XCenter do
  it_behaves_like 'Part', XCenter
end
