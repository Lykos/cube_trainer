# frozen_string_literal: true

require 'twisty_puzzles'

def transform_symbols_to_strings(value)
  case value
  when Hash
    value.map { |k, v| [transform_symbols_to_strings(k), transform_symbols_to_strings(v)] }.to_h
  when Array
    value.map { |v| transform_symbols_to_strings(v) }
  when Symbol
    value.to_s
  else
    value
  end
end

RSpec::Matchers.define(:eq_modulo_symbol_vs_string) do |expected|
  match do |actual|
    transform_symbols_to_strings(actual) == transform_symbols_to_strings(expected)
  end
end

# TODO: Don't copy these from the twisty_puzzles gem.
RSpec::Matchers.define(:eq_commutator) do |expected|
  include TwistyPuzzles

  match do |actual|
    expected = parse_commutator(expected) if expected.is_a?(String)
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal commutator #{expected}"
  end
end

# TODO: Don't copy these from the twisty_puzzles gem.
RSpec::Matchers.define(:eq_sarahs_skewb_algorithm) do |expected|
  include TwistyPuzzles

  match do |actual|
    if expected.is_a?(String)
      expected = parse_skewb_algorithm(expected, TwistyPuzzles::SkewbNotation.sarah)
    end
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected} (using sarah's notation)"
  end
end
