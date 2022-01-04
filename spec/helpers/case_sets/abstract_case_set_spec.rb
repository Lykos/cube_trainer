# frozen_string_literal: true

require 'rails_helper'
require 'case_sets/abstract_case_set'
require 'case_sets/concrete_case_set'

describe CaseSets::AbstractCaseSet do
  describe '#all' do
    it 'returns a non-empty array' do
      expect(described_class.all).not_to be_empty
    end

    it 'returns an array whose elements without buffer can be refined with no arguments' do
      without_buffer = described_class.all.reject(&:buffer?)
      refinements = without_buffer.map(&:refinement)
      expect(refinements.all?(CaseSets::ConcreteCaseSet)).to be(true)
    end

    it 'returns an array whose elements with buffer can be refined with an element of its buffer type' do
      with_buffer = described_class.all.select(&:buffer?)
      refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
      expect(refinements.all?(CaseSets::ConcreteCaseSet)).to be(true)
    end
  end
end
