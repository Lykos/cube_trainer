# frozen_string_literal: true

require 'case_sets/abstract_case_set'
require 'case_sets/concrete_case_set'
require 'cube_trainer/sheet_scraping/case_set_setup_finder'
require 'twisty_puzzles'
require 'rails_helper'

describe CubeTrainer::CaseSetSetupFinder do
  with_buffer = CaseSets::AbstractCaseSet.all.select(&:buffer?)
  without_buffer = CaseSets::AbstractCaseSet.all.reject(&:buffer?)
  without_buffer_refinements = without_buffer.map(&:refinement)
  with_buffer_refinements = with_buffer.map { |c| c.refinement(c.buffer_part_type::ELEMENTS.first) }
  concrete_case_sets = with_buffer_refinements + without_buffer_refinements

  concrete_case_sets.each do |concrete_case_set|
    it "Finds a setup for case #{concrete_case_set.cases.first} in #{concrete_case_set}." do
      CaseSetSetupFinder.new(concrete_case_set).find_setup(concrete_case_set.cases.first)
    end
  end
end
