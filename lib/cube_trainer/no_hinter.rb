# frozen_string_literal: true

module CubeTrainer
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
