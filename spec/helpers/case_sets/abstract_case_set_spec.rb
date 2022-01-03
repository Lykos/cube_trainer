describe CaseSets::AbstractCaseSet do
  describe '#all' do
    it 'returns a non-empty array' do
      expect(described_class.all).not_to be_empty
    end

    it 'returns an array whose elements without buffer can be refined with no arguments' do
      without_buffer = described_class.all.reject { |c| c.buffer? }
      refinements = without_buffer.map(&:refinement)
      expect(refinements.all?(CaseSets::ConcreteCaseSet)).to be(true)
    end

    it 'returns an array whose elements with buffer can be refined with an element of its buffer type' do
      with_buffer = described_class.all.select { |c| c.buffer? }
      refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
      expect(refinements.all?(CaseSets::ConcreteCaseSet)).to be(true)
    end

    it 'returns an array whose elements whose refinements produce strict matching cases' do
      with_buffer = described_class.all.select { |c| c.buffer? }
      without_buffer = described_class.all.reject { |c| c.buffer? }
      without_buffer_refinements = without_buffer.map(&:refinement)
      with_buffer_refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
      refinements = with_buffer_refinements + without_buffer_refinements
      refinements.each do |r|
        cases = r.cases
        expect(cases.all?(Case)).to be_true
        expect(cases.all? { |c| r.strict_matching?(c) }).to be(true)
      end
    end
  end
end
