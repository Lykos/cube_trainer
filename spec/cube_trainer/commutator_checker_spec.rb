# frozen_string_literal: true

require 'cube_trainer/color_scheme'
require 'cube_trainer/commutator_checker'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/parser'
require 'cube_trainer/letter_pair'
require 'cube_trainer/letter_scheme'

describe CommutatorChecker do
  include Core

  let(:part_type) { Core::Corner }
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:piece_name) { 'corner' }
  let(:buffer) { letter_scheme.default_buffer(part_type) }
  let(:checker) do
    described_class.new(
      part_type: part_type,
      buffer: buffer,
      piece_name: piece_name,
      color_scheme: color_scheme,
      letter_scheme: letter_scheme,
      cube_size: cube_size,
      verbose: false,
      find_fixes: true
    )
  end
  let(:row_description) { 'some row' }

  it 'deems a correct algorithm correct' do
    result = checker.check_alg(row_description, LetterPair.new(%w[i g]), parse_commutator("[L', U R U']"))
    expect(result.result).to be == :correct
    expect(result.fix).to be_nil
  end

  it 'fixes an algorithm that has to be inverted' do
    result = checker.check_alg(row_description, LetterPair.new(%w[i g]), parse_commutator("[U R U', L']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where one move in the insert has to be inverted' do
    result = checker.check_alg(row_description, LetterPair.new(%w[i g]), parse_commutator("[L', U' R U']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where the interchange has to be inverted' do
    result = checker.check_alg(row_description, LetterPair.new(%w[i g]), parse_commutator("[L, U R U']"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[L', U R U']")
  end

  it 'fixes an algorithm where the setup has to be inverted' do
    result = checker.check_alg(row_description, LetterPair.new(%w[i e]), parse_commutator("[F : [L', U R U']]"))
    expect(result.result).to be == :fix_found
    expect(result.fix).to eq_commutator("[F' : [L', U R U']]")
  end

  it 'says unfixable if no fix is in sight' do
    result = checker.check_alg(row_description, LetterPair.new(%w[j g]), parse_commutator('[M, U]'))
    expect(result.result).to be == :unfixable
    expect(result.fix).to be_nil
  end
end
