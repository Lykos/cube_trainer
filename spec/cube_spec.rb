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
