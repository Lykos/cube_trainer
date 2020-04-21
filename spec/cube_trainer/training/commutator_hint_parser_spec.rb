# frozen_string_literal: true

require 'twisty_puzzles'
require 'twisty_puzzles'
require 'cube_trainer/training/commutator_hint_parser'
require 'twisty_puzzles'

describe Training::HintParser do
  include TwistyPuzzles

  let(:part_type) { TwistyPuzzles::Corner }
  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:buffer) { letter_scheme.default_buffer(part_type) }
  let(:hint_parser) do
    Training::CommutatorHintParser.new(
      part_type: part_type,
      buffer: buffer,
      letter_scheme: letter_scheme,
      color_scheme: TwistyPuzzles::ColorScheme::BERNHARD,
      verbose: false,
      cube_size: 3,
      test_comms_mode: :ignore
    )
  end

  it 'parses a valid hint table correctly' do
    table = [
      ["[L', U R U']", '', "[L', U R' U']"],
      ['', "[U R U', L']", "[D U R U' : [R' U R, D']]"],
      ["[D U R U' : [D', R' U R]]", "[U R' U', L']", '']
    ]
    expect(hint_parser.parse_hint_table(table)).to eq(
      {
        LetterPair.new(%w[i g]) => parse_commutator("[L', U R U']"),
        LetterPair.new(%w[g i]) => parse_commutator("[U R U', L']"),
        LetterPair.new(%w[t g]) => parse_commutator("[L', U R' U']"),
        LetterPair.new(%w[g t]) => parse_commutator("[U R' U', L']"),
        LetterPair.new(%w[i t]) => parse_commutator("[D U R U' : [D', R' U R]]"),
        LetterPair.new(%w[t i]) => parse_commutator("[D U R U' : [R' U R, D']]")
      }
    )
  end

  it 'parses a hint table with single entries per row/column correctly' do
    table = [
      ["[L', U R U']", ''],
      ['', "[U R U', L']"]
    ]
    expect(hint_parser.parse_hint_table(table)).to eq(
      {
        LetterPair.new(%w[i g]) => parse_commutator("[L', U R U']"),
        LetterPair.new(%w[g i]) => parse_commutator("[U R U', L']")
      }
    )
  end
end
