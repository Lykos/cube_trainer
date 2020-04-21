# frozen_string_literal: true

require 'twisty_puzzles/parser'
require 'twisty_puzzles/cube_move_parser'
require 'twisty_puzzles/skewb_move_parser'
require 'twisty_puzzles/skewb_notation'

RSpec::Matchers.define(:eq_cube_coordinate) do |expected_face,
                                                expected_cube_size,
                                                expected_x,
                                                expected_y|
  expected = Coordinate.from_indices(
    expected_face, expected_cube_size, expected_x, expected_y
  )

  match do |actual|
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal coordinate #{expected}"
  end
end

RSpec::Matchers.define(:eq_move) do |expected|
  

  match do |actual|
    expected = parse_move(expected) if expected.is_a?(String)
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal move #{expected}"
  end
end

RSpec::Matchers.define(:equivalent_cube_algorithm) do |expected, cube_size, color_scheme|
  

  match do |actual|
    expected = parse_algorithm(expected) if expected.is_a?(String)
    expected_cube_state = color_scheme.solved_cube_state(cube_size)
    expected.apply_to(expected_cube_state)
    actual_cube_state = color_scheme.solved_cube_state(cube_size)
    actual.apply_to(actual_cube_state)

    actual_cube_state == expected_cube_state
  end
  failure_message do |actual|
    expected = parse_algorithm(expected) if expected.is_a?(String)
    expected_cube_state = color_scheme.solved_cube_state(cube_size)
    expected.apply_to(expected_cube_state)
    actual_cube_state = color_scheme.solved_cube_state(cube_size)
    actual.apply_to(actual_cube_state)

    "expected that #{actual} would have the same effect on the cube as #{expected}.\n" \
    "Got:\n#{actual_cube_state.colored_to_s}\ninstead of:\n#{expected_cube_state.colored_to_s}"
  end
end

RSpec::Matchers.define(:eq_cube_algorithm) do |expected|
  

  match do |actual|
    expected = parse_algorithm(expected) if expected.is_a?(String)
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected}"
  end
end

RSpec::Matchers.define(:equivalent_skewb_algorithm) do |expected, color_scheme|
  

  match do |actual|
    expected_skewb_state = color_scheme.solved_skewb_state
    expected.apply_to(expected_skewb_state)
    actual_skewb_state = color_scheme.solved_skewb_state
    actual.apply_to(actual_skewb_state)

    actual_skewb_state == expected_skewb_state
  end
  failure_message do |actual|
    expected_skewb_state = color_scheme.solved_skewb_state
    expected.apply_to(expected_skewb_state)
    actual_skewb_state = color_scheme.solved_skewb_state
    actual.apply_to(actual_skewb_state)

    "expected that #{actual} would have the same effect on the skewb as #{expected}.\n" \
    "Got:\n#{actual_skewb_state.colored_to_s}\ninstead of:\n#{expected_skewb_state.colored_to_s}"
  end
end

RSpec::Matchers.define(:equivalent_sarahs_skewb_algorithm) do |expected, color_scheme|
  

  match do |actual|
    expected = parse_skewb_algorithm(expected, SkewbNotation.sarah) if expected.is_a?(String)
    expected_skewb_state = color_scheme.solved_skewb_state
    expected.apply_to(expected_skewb_state)
    actual_skewb_state = color_scheme.solved_skewb_state
    actual.apply_to(actual_skewb_state)

    actual_skewb_state == expected_skewb_state
  end
  failure_message do |actual|
    expected = parse_skewb_algorithm(expected, SkewbNotation.sarah) if expected.is_a?(String)
    expected_skewb_state = color_scheme.solved_skewb_state
    expected.apply_to(expected_skewb_state)
    actual_skewb_state = color_scheme.solved_skewb_state
    actual.apply_to(actual_skewb_state)

    "expected that #{actual} would have the same effect on the skewb as #{expected}.\n" \
    "Got:\n#{actual_skewb_state.colored_to_s}\ninstead of:\n#{expected_skewb_state.colored_to_s}"
  end
end

RSpec::Matchers.define(:eq_sarahs_skewb_algorithm) do |expected|
  

  match do |actual|
    expected = parse_skewb_algorithm(expected, SkewbNotation.sarah) if expected.is_a?(String)
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected} (using sarah's notation)"
  end
end

RSpec::Matchers.define(:eq_fixed_corner_skewb_algorithm) do |expected|
  

  match do |actual|
    if expected.is_a?(String)
      expected = parse_skewb_algorithm(expected, SkewbNotation.fixed_corner)
    end
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected} (using fixed corner notation)"
  end
end

RSpec::Matchers.define(:eq_commutator) do |expected|
  

  match do |actual|
    expected = parse_commutator(expected) if expected.is_a?(String)
    actual == expected
  end
  failure_message do |actual|
    "expected that #{actual} would equal commutator #{expected}"
  end
end

RSpec::Matchers.define(:eq_puzzle_state) do |expected|
  

  match do |actual|
    actual == expected
  end
  failure_message do |actual|
    "expected that:\n#{actual.colored_to_s}\nwould equal:\n#{expected.colored_to_s}"
  end
end

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

