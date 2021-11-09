# frozen_string_literal: true

require 'cube_trainer/training/commutator_hint_parser'
require 'twisty_puzzles'

describe Training::CommutatorHintParser do
  include TwistyPuzzles

  let(:part_type) { TwistyPuzzles::Corner }
  let(:letter_scheme) { TwistyPuzzles::BernhardLetterScheme.new }
  let(:buffer) { letter_scheme.default_buffer(part_type) }
  let(:hint_parser) do
    described_class.new(
      part_type: part_type,
      buffer: buffer,
      letter_scheme: letter_scheme,
      color_scheme: TwistyPuzzles::ColorScheme::BERNHARD,
      verbose: false,
      show_cube_states: false,
      cube_size: 3,
      test_comms_mode: :ignore,
      write_fixes: false
    )
  end
  let(:i) { part_type.for_face_symbols(%i[R B U]) }
  let(:t) { part_type.for_face_symbols(%i[B R D]) }
  let(:g) { part_type.for_face_symbols(%i[F L U]) }

  it 'parses a valid hint table correctly' do
    table = [
      ["[L', U R U']", '', "[L', U R' U']"],
      ['', "[U R U', L']", "[D U R U' : [R' U R, D']]"],
      ["[D U R U' : [D', R' U R]]", "[U R' U', L']", '']
    ]
    expect(hint_parser.parse_hint_table(table, table)).to eq(
      {
        TwistyPuzzles::PartCycle.new([buffer, i, g]) => parse_commutator("[L', U R U']"),
        TwistyPuzzles::PartCycle.new([buffer, g, i]) => parse_commutator("[U R U', L']"),
        TwistyPuzzles::PartCycle.new([buffer, t, g]) => parse_commutator("[L', U R' U']"),
        TwistyPuzzles::PartCycle.new([buffer, g, t]) => parse_commutator("[U R' U', L']"),
        TwistyPuzzles::PartCycle.new([buffer, i, t]) => parse_commutator("[D U R U' : [D', R' U R]]"),
        TwistyPuzzles::PartCycle.new([buffer, t, i]) => parse_commutator("[D U R U' : [R' U R, D']]")
      }
    )
  end

  it 'parses a hint table with single entries per row/column correctly' do
    table = [
      ["[L', U R U']", ''],
      ['', "[U R U', L']"]
    ]
    expect(hint_parser.parse_hint_table(table, table)).to eq(
      {
        TwistyPuzzles::PartCycle.new([buffer, i, g]) => parse_commutator("[L', U R U']"),
        TwistyPuzzles::PartCycle.new([buffer, g, i]) => parse_commutator("[U R U', L']")
      }
    )
  end
end
