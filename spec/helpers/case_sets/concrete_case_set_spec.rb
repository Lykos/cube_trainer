require 'rails_helper'
require 'case_sets/abstract_case_set'
require 'case_sets/concrete_case_set'

class StubLetterScheme
  def letter(part)
    'A'
  end
end

describe CaseSets::AbstractCaseSet do
  let(:concrete_case_sets) do
    with_buffer = described_class.all.select { |c| c.buffer? }
    without_buffer = described_class.all.reject { |c| c.buffer? }
    without_buffer_refinements = without_buffer.map(&:refinement)
    with_buffer_refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
    with_buffer_refinements + without_buffer_refinements
  end

  it 'produces non-empty cases' do
    concrete_case_sets.each do |r|
      expect(r.cases).not_to be_empty
    end
  end

  it 'produces strict matching cases' do
    concrete_case_sets.each do |r|
      expect(r.cases.all?(Case)).to be(true)
    end
  end

  it 'produces strict matching cases' do
    concrete_case_sets.each do |r|
      r.cases.each do |c|
        expect(r.strict_match?(c)).to be(true)
      end
    end
  end

  it 'produces case names with a letter scheme' do
    concrete_case_sets.each do |r|
      r.cases.each do |c|
        expect(r.case_name(c, letter_scheme: StubLetterScheme.new)).to be_a(String)
      end
    end
  end

  it 'produces case names without a letter scheme' do
    concrete_case_sets.each do |r|
      r.cases.each do |c|
        expect(r.case_name(c)).to be_a(String)
      end
    end
  end
end
