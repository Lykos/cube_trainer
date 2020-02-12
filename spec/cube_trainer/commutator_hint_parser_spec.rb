# frozen_string_literal: true

require 'cube_trainer/core/cube'
require 'cube_trainer/core/parser'
require 'cube_trainer/commutator_hint_parser'
require 'cube_trainer/letter_scheme'

describe HintParser do
  let(:part_type) { Corner }
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:buffer) { letter_scheme.default_buffer(part_type) }
  let(:hint_parser) do
    CommutatorHintParser.new(
      part_type: part_type,
      buffer: buffer,
      letter_scheme: letter_scheme,
      color_scheme: ColorScheme::BERNHARD,
      verbose: false,
      cube_size: 3,
      test_comms_mode: :ignore
    )
  end

  it 'should parse a valid hint table correctly' do
    table = [
      ["[L', U R U']", '', "[L', U R' U']"],
      ['', "[U R U', L']", "[D U R U' : [R' U R, D']]"],
      ["[D U R U' : [D', R' U R]]", "[U R' U', L']", '']
    ]
    expect(hint_parser.parse_hint_table(table)).to be == {
      LetterPair.new(%w[i g]) => parse_commutator("[L', U R U']"),
      LetterPair.new(%w[g i]) => parse_commutator("[U R U', L']"),
      LetterPair.new(%w[t g]) => parse_commutator("[L', U R' U']"),
      LetterPair.new(%w[g t]) => parse_commutator("[U R' U', L']"),
      LetterPair.new(%w[i t]) => parse_commutator("[D U R U' : [D', R' U R]]"),
      LetterPair.new(%w[t i]) => parse_commutator("[D U R U' : [R' U R, D']]")
    }
  end

  it 'should parse a hint table with single entries per row/column correctly' do
    table = [
      ["[L', U R U']", ''],
      ['', "[U R U', L']"]
    ]
    expect(hint_parser.parse_hint_table(table)).to be == {
      LetterPair.new(%w[i g]) => parse_commutator("[L', U R U']"),
      LetterPair.new(%w[g i]) => parse_commutator("[U R U', L']")
    }
  end
end
