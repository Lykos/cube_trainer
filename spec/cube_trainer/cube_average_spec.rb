# frozen_string_literal: true

require 'cube_trainer/native'

describe Native::CubeAverage do
  let(:average_computer) { described_class.new(5, 6) }

  it 'returns the default average initially' do
    expect(average_computer.average).to be == 6
  end

  it 'raises an error if a non-numeric type gets pushed' do
    expect { average_computer.push('0') }.to raise_error(TypeError)
  end

  context 'when it has one element' do
    before do
      average_computer.push(3)
    end

    it 'returns the only element as the average' do
      expect(average_computer.average).to be == 3
    end

    it 'is not saturated' do
      expect(average_computer).not_to(be_saturated)
    end
  end

  context 'when it has two elements' do
    before do
      average_computer.push(3)
      average_computer.push(6)
    end

    it 'returns the mathematical average as the average' do
      expect(average_computer.average).to be == 4.5
    end

    it 'is not saturated' do
      expect(average_computer).not_to(be_saturated)
    end
  end

  context 'when it has more than two elements, but not enough to be saturated' do
    before do
      average_computer.push(3)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
    end

    it 'returns the mathematical average without the top and bottom element as the average' do
      expect(average_computer.average).to be == 4.5
    end

    it 'is not saturated' do
      expect(average_computer).not_to(be_saturated)
    end
  end

  context 'when it has as many elements as it needs to be saturated' do
    before do
      average_computer.push(2)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
      average_computer.push(4)
    end

    it 'returns the mathematical average without the top and bottom element as the average' do
      expect(average_computer.average).to be == 4
    end

    it 'is saturated' do
      expect(average_computer).to be_saturated
    end
  end

  context 'when elements get pushed after it is saturated' do
    before do
      average_computer.push(2)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
      average_computer.push(4)
      average_computer.push(5)
    end

    it 'returns the mathematical average without the element that gets thrown out, the top and bottom element as the average' do
      expect(average_computer.average).to be == 5
    end

    it 'is not saturated' do
      expect(average_computer).to be_saturated
    end
  end
end
