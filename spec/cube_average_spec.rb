require 'cube_average'

describe CubeAverage do
  before do
    @average = CubeAverage.new(5, 6)
  end
  
  it "should return the default average initially" do
    @average.average.should == 6
  end

  context "when it has one element" do
    before do
      @average.push(3)
    end
    
    it "should return the only element as the average" do
      @average.average.should == 3
    end
    
    it "should not be saturated" do
      @average.should_not be_saturated
    end
  end

  context "when it has two elements" do
    before do
      @average.push(3)
      @average.push(6)
    end
    
    it "should return the mathematical average as the average" do
      expect(@average.average).to be == 4.5
    end
    
    it "should not be saturated" do
      expect(@average).not_to be_saturated
    end
  end

  context "when it has more than two elements, but not enough to be saturated" do
    before do
      @average.push(3)
      @average.push(1)
      @average.push(7)
      @average.push(6)
    end
    
    it "should return the mathematical average without the top and bottom element as the average" do
      expect(@average.average).to be == 4.5
    end
    
    it "should not be saturated" do
      expect(@average).not_to be_saturated
    end
  end

  context "when it has as many elements as it needs to be saturated" do
    before do
      @average.push(2)
      @average.push(1)
      @average.push(7)
      @average.push(6)
      @average.push(4)
    end
    
    it "should return the mathematical average without the top and bottom element as the average" do
      expect(@average.average).to be == 4
    end
    
    it "should be saturated" do
      expect(@average).to be_saturated
    end
  end

  context "when elements get pushed after it is saturated" do
    before do
      @average.push(2)
      @average.push(1)
      @average.push(7)
      @average.push(6)
      @average.push(4)
      @average.push(5)
    end
    
    it "should return the mathematical average without the element that gets thrown out, the top and bottom element as the average" do
      expect(@average.average).to be == 5
    end
    
    it "should not be saturated" do
      expect(@average).to be_saturated
    end
  end
end
