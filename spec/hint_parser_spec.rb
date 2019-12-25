require 'cube'
require 'letter_scheme'
require 'hint_parser'
require 'parser'

include CubeTrainer

describe HintParser do
  let (:part_type) { Corner }
  let (:letter_scheme) { DefaultLetterScheme.new }
  let (:buffer) { letter_scheme.default_buffer(part_type) }
  let (:verbose) { false }
  let (:test_comms) { false }
  let (:cube_size) { 3 }
  let (:hint_parser) { HintParser.new(part_type, buffer, letter_scheme, verbose, cube_size, test_comms) }

  it "should parse a valid hint table correctly" do
    table = [
      ["[L', U R U']", "", "[L', U R' U']"], 
      ["", "[U R U', L']", "[D U R U' : [R' U R, D']]"],
      ["[D U R U' : [D', R' U R]]", "[U R' U', L']", ""],
    ]
    expect(hint_parser.parse_hint_table(table)).to be == {
      LetterPair.new(['i', 'g']) => parse_commutator("[L', U R U']"),
      LetterPair.new(['g', 'i']) => parse_commutator("[U R U', L']"),
      LetterPair.new(['t', 'g']) => parse_commutator("[L', U R' U']"),
      LetterPair.new(['g', 't']) => parse_commutator("[U R' U', L']"),
      LetterPair.new(['i', 't']) => parse_commutator("[D U R U' : [D', R' U R]]"),
      LetterPair.new(['t', 'i']) => parse_commutator("[D U R U' : [R' U R, D']]"),
    }
  end

  it "should parse a hint table with single entries per row/column correctly" do
    table = [
      ["[L', U R U']", ""], 
      ["", "[U R U', L']"]
    ]
    expect(hint_parser.parse_hint_table(table)).to be == {
      LetterPair.new(['i', 'g']) => parse_commutator("[L', U R U']"),
      LetterPair.new(['g', 'i']) => parse_commutator("[U R U', L']"),
    }
  end
end
