# frozen_string_literal: true

require 'cube_trainer/commutator_checker'
require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/letter_pair'
require 'twisty_puzzles'

def cell_description(*parts)
  Training::CommutatorHintParser::CellDescription.new('test', 0, 0, TwistyPuzzles::PartCycle.new(parts))
end

describe CommutatorChecker do
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
      part_type: part_type,
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
