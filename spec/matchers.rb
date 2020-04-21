# frozen_string_literal: true

RSpec::Matchers.define(:eq_modulo_symbol_vs_string) do |expected|
  match do |actual|
    transform_symbols_to_strings(actual) == transform_symbols_to_strings(expected)
  end
end
