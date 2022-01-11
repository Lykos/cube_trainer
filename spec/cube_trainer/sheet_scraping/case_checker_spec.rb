# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/case_checker'
require 'twisty_puzzles'
require 'rails_helper'

def cell_description(*parts)
  part_patterns = parts.map { |p| CasePattern::SpecificPart.new(p) }
  part_cycle_patterns = [CasePattern::PartCyclePattern.new(parts.first.class, part_patterns)]
  case_pattern = CasePattern::LeafCasePattern.new(part_cycle_patterns)
  SheetScraping::AlgExtractor::CellDescription.new('test', 0, 0, case_pattern)
end

describe CaseChecker do
  include TwistyPuzzles

  let(:part_type) { TwistyPuzzles::Corner }
  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:piece_name) { 'corner' }
  let(:buffer) { letter_scheme.default_buffer(part_type) }
  let(:e) { part_type.for_face_symbols(%i[F R U]) }
  let(:i) { part_type.for_face_symbols(%i[R B U]) }
  let(:j) { part_type.for_face_symbols(%i[R F U]) }
  let(:g) { part_type.for_face_symbols(%i[F L U]) }
  let(:checker) do
    described_class.new(
      cube_size: cube_size,
      verbose: false,
      find_fixes: true
    )
  end

  it 'deems a correct algorithm correct' do
    result = checker.check_alg(cell_description(buffer, i, g), parse_commutator("[L', U R U']"))
    expect(result.result).to be == :correct
    expect(result.fix).to be_nil
  end

  it 'fixes an algorithm that has to be inverted' do
    result = checker.check_alg(cell_description(buffer, i, g), parse_commutator("[U R U', L']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where one move in the insert has to be inverted' do
    result = checker.check_alg(cell_description(buffer, i, g), parse_commutator("[L', U' R U']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where the interchange has to be inverted' do
    result = checker.check_alg(cell_description(buffer, i, g), parse_commutator("[L, U R U']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where the setup has to be inverted' do
    result = checker.check_alg(cell_description(buffer, i, e), parse_commutator("[F : [L', U R U']]"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[F' : [L', U R U']]")
  end

  it 'says unfixable if no fix is in sight' do
    result = checker.check_alg(cell_description(buffer, j, g), parse_commutator('[M, U]'))
    expect(result.result).to be == :unfixable
    expect(result.fix).to be_nil
  end
end
