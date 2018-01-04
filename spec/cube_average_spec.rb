require 'cube_average'

include CubeTrainer

describe CubeAverage do
  let (:average_computer) { CubeAverage.new(5, 6) }
  
  it "should return the default average initially" do
    expect(average_computer.average).to be == 6
  end

  context "when it has one element" do
    before do
      average_computer.push(3)
    end
    
    it "should return the only element as the average" do
      expect(average_computer.average).to be == 3
    end
    
    it "should not be saturated" do
      expect(average_computer).not_to be_saturated
    end
  end

  context "when it has two elements" do
    before do
      average_computer.push(3)
      average_computer.push(6)
    end
    
    it "should return the mathematical average as the average" do
      expect(average_computer.average).to be == 4.5
    end
    
    it "should not be saturated" do
      expect(average_computer).not_to be_saturated
    end
  end

  context "when it has more than two elements, but not enough to be saturated" do
    before do
      average_computer.push(3)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
    end
    
    it "should return the mathematical average without the top and bottom element as the average" do
      expect(average_computer.average).to be == 4.5
    end
    
    it "should not be saturated" do
      expect(average_computer).not_to be_saturated
    end
  end

  context "when it has as many elements as it needs to be saturated" do
    before do
      average_computer.push(2)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
      average_computer.push(4)
    end
    
    it "should return the mathematical average without the top and bottom element as the average" do
      expect(average_computer.average).to be == 4
    end
    
    it "should be saturated" do
      expect(average_computer).to be_saturated
    end
  end

  context "when elements get pushed after it is saturated" do
    before do
      average_computer.push(2)
      average_computer.push(1)
      average_computer.push(7)
      average_computer.push(6)
      average_computer.push(4)
      average_computer.push(5)
    end
    
    it "should return the mathematical average without the element that gets thrown out, the top and bottom element as the average" do
      expect(average_computer.average).to be == 5
    end
    
    it "should not be saturated" do
      expect(average_computer).to be_saturated
    end
  end
end
