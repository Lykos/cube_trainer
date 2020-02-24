# frozen_string_literal: true

require 'cube_trainer/core/parser'
require 'cube_trainer/core/cube_move_parser'
require 'cube_trainer/core/skewb_move_parser'

RSpec::Matchers.define(:eq_cube_coordinate) do |expected_face,
                                                expected_cube_size,
                                                expected_x,
                                                expected_y|
  expected = Core::Coordinate.from_indices(
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
  include Core

  match do |actual|
    actual == parse_move(expected)
  end
  failure_message do |actual|
    "expected that #{actual} would equal move #{expected}"
  end
end

RSpec::Matchers.define(:eq_cube_algorithm) do |expected|
  include Core

  match do |actual|
    actual == parse_algorithm(expected)
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected}"
  end
end

RSpec::Matchers.define(:eq_sarahs_skewb_algorithm) do |expected|
  include Core

  match do |actual|
    actual == parse_sarahs_skewb_algorithm(expected)
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected} (using sarah's notation)"
  end
end

RSpec::Matchers.define(:eq_fixed_corner_skewb_algorithm) do |expected|
  include Core

  match do |actual|
    actual == parse_fixed_corner_skewb_algorithm(expected)
  end
  failure_message do |actual|
    "expected that #{actual} would equal algorithm #{expected} (using fixed corner notation)"
  end
end

RSpec::Matchers.define(:eq_commutator) do |expected|
  include Core

  match do |actual|
    actual == parse_commutator(expected)
  end
  failure_message do |actual|
    "expected that #{actual} would equal commutator #{expected}"
  end
end

RSpec::Matchers.define(:eq_puzzle_state) do |expected|
  include Core

  match do |actual|
    actual == expected
  end
  failure_message do |actual|
    "expected that:\n#{actual.colored_to_s}\nwould equal:\n#{expected.colored_to_s}"
  end
end
