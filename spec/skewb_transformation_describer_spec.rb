require 'parser'
require 'skewb_transformation_describer'

include CubeTrainer

CYCLE_REGEXP = Regexp.new("#{SkewbTransformationDescriber::DOUBLE_ARROW}|#{SkewbTransformationDescriber::ARROW}")
                                                                        
def canonicalize_description(description)
  description.split(SkewbTransformationDescriber::DESCRIPTION_SEPARATOR).map do |s|
    parts = s.split(CYCLE_REGEXP)
    parts = parts[0..-2] if parts[0] == parts[-1]
    parts.rotate(parts.index(parts.min))
  end.sort
end

RSpec::Matchers.define :be_the_same_description_as do |expected|
  match do |actual|
    canonicalize_description(expected) == canonicalize_description(actual)
  end
end

describe SkewbTransformationDescriber do
  let(:yellow_corners) { Corner::ELEMENTS.select { |c| c.colors.first == :yellow } }
  let(:non_bottom_faces) { Face::ELEMENTS.select { |c| c.color != :white } }
  let(:describer) { SkewbTransformationDescriber.new(non_bottom_faces, yellow_corners) }

  it 'should describe sledges accurately' do
    alg = parse_sarahs_skewb_algorithm("F' L F L'")
    expect(describer.description(alg)).to be_the_same_description_as "F <-> U, R <-> L, UFL -> LUF, URF -> FUR, ULB -> LBU, UBR -> BRU"
  end

  it 'should describe F moves accurately' do
    alg = parse_sarahs_skewb_algorithm("F")
    expect(describer.description(alg)).to be_the_same_description_as "U -> R -> F -> U, URF -> RFU, UFL -> RUB -> FRD -> UFL"
  end
end
