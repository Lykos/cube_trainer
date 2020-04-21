# frozen_string_literal: true

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
