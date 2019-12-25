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
      ["[L', U R' U]", ""], 
      ["", "[U R' U, L']"],
    ]
    expect(hint_parser.parse_hint_table(table)).to == {
      LetterPair.new(['i', 'g']) => parse_commutator("[L', U R' U]"),
      LetterPair.new(['g', 'i']) => parse_commutator("[U R' U, L']"),
    }
  end
end
