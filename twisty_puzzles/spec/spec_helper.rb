# frozen_string_literal: true

require 'simplecov'

# TODO: Find the proper way to do this
ENV['RANTLY_VERBOSE'] ||= '0'

RSpec.configure do |config|
  # Allow for writing `describe` instead of `RSpec.describe`.
  config.expose_dsl_globally = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/examples.txt'

  # Only enable the expect(x).to syntax.
  config.expect_with(:rspec) do |expectations|
    expectations.syntax = :expect
  end

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end

# This must be before we require twisty_puzzles.
SimpleCov.start do
  add_filter '/spec/'
end

require 'twisty_puzzles'
require 'generator_helpers'
require 'matchers'
require 'shrink_helpers'

include TwistyPuzzles # rubocop:disable Style/MixinUsage

