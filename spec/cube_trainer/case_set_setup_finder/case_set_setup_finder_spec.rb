# frozen_string_literal: true

require 'case_sets/abstract_case_set'
require 'case_sets/concrete_case_set'
require 'cube_trainer/case_set_setup_finder/case_set_setup_finder'
require 'twisty_puzzles'
require 'rails_helper'

def canonicalize(casee)
  casee.canonicalize(ignore_same_face_center_cycles: true)
end

def arbitrary_refine(abstract_alg_set)
  arbitrary_buffer = abstract_alg_set.buffer_part_type::ELEMENTS.first
  abstract_alg_set.refinement(arbitrary_buffer)
end

describe CubeTrainer::CaseSetSetupFinder::CaseSetSetupFinder do
  with_buffer = CaseSets::AbstractCaseSet.all.select(&:buffer?)
  without_buffer = CaseSets::AbstractCaseSet.all.reject(&:buffer?)
  without_buffer_refinements = without_buffer.map(&:refinement)
  with_buffer_refinements = with_buffer.map { |c| arbitrary_refine(c) }
  concrete_case_sets = with_buffer_refinements + without_buffer_refinements

  concrete_case_sets.each do |case_set|
    context case_set do
      let(:case_reverse_engineer) do
        CubeTrainer::CaseReverseEngineer.new(
          cube_size: case_set.default_cube_size
        )
      end

      casee = case_set.cases.first

      it "Finds a setup for case #{casee} in #{case_set}." do
        alg = CaseSetSetupFinder::CaseSetSetupFinder.new(case_set).find_setup(casee)
        expect(alg).not_to be_nil
        found_case = case_reverse_engineer.find_case(alg.inverse)
        expect(canonicalize(found_case)).to eq(canonicalize(casee))
      end
    end
  end
end
