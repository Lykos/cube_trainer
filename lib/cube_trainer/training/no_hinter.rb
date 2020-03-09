# frozen_string_literal: true

module CubeTrainer
  # An empty hinter that always returns no hints.
  class NoHinter
    def initialize(keys)
      @entries = keys.map { |k| [k, nil] }
    end

    attr_reader :entries

    def hints(*_args)
      []
    end
  end
end
