# frozen_string_literal: true

require 'rails_helper'
require 'case_sets/abstract_case_set'
require 'case_sets/concrete_case_set'

class StubLetterScheme
  def letter(_part)
    'A'
  end
end

describe CaseSets::ConcreteCaseSet do
  with_buffer = CaseSets::AbstractCaseSet.all.select(&:buffer?)
  without_buffer = CaseSets::AbstractCaseSet.all.reject(&:buffer?)
  without_buffer_refinements = without_buffer.map(&:refinement)
  with_buffer_refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
  concrete_case_sets = with_buffer_refinements + without_buffer_refinements

  concrete_case_sets.each do |concrete_case_set|
    describe concrete_case_set do
      it 'can be found by name' do
        class_name = described_class.simple_class_name(concrete_case_set.class)
        expect(described_class.class_by_name(class_name)).to eq(concrete_case_set.class)
      end

      it 'can be serialized and deserialized' do
        serialized = concrete_case_set.to_raw_data
        expect(described_class.from_raw_data(serialized)).to eq(concrete_case_set)
      end

      it 'produces non-empty cases' do
        expect(concrete_case_set.cases).not_to be_empty
      end

      it 'produces cases' do
        expect(concrete_case_set.cases.all?(Case)).to be(true)
      end

      it 'produces strict matching cases' do
        concrete_case_set.cases.each do |c|
          expect(concrete_case_set.strict_match?(c)).to be(true)
        end
      end

      it 'produces case names with a letter scheme' do
        concrete_case_set.cases.each do |c|
          expect(concrete_case_set.case_name(c, letter_scheme: StubLetterScheme.new)).to be_a(String)
        end
      end

      it 'produces case names without a letter scheme' do
        concrete_case_set.cases.each do |c|
          expect(concrete_case_set.case_name(c)).to be_a(String)
        end
      end
    end
  end
end
