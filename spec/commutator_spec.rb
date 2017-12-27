require 'commutator'

describe PureCommutator do
  let (:commutator) { parse_commutator('[R, U\' L\' U]') }
  
  it "should be equal to the inverse of its inverse" do
    expect(commutator.inverse.inverse).to be == commutator
  end

  it "should be inverted appropriately" do
    expect(commutator.inverse.to_s).to be == '[U\' L\' U, R]'
  end

  it "should be printed appropriately" do
    expect(commutator.to_s).to be == '[R, U\' L\' U]'
  end
end

describe SetupCommutator do
  let (:commutator) { parse_commutator('[U\' : [R, U\' L\' U]]') }
  
  it "should be equal to the inverse of its inverse" do
    expect(commutator.inverse.inverse).to be == commutator
  end

  it "should be inverted appropriately" do
    expect(commutator.inverse.to_s).to be == '[U\' : [U\' L\' U, R]]'
  end

  it "should be printed appropriately" do
    expect(commutator.to_s).to be == '[U\' : [R, U\' L\' U]]'
  end
end
