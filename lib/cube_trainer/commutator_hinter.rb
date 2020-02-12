# frozen_string_literal: true

module CubeTrainer
  class CommutatorHinter
    def initialize(hints)
      @hints = hints.map { |k, v| [k, [v]] }.to_h
    end

    def hints(letter_pair)
      @hints[letter_pair] ||= begin
                                inverse = @hints[letter_pair.inverse]
                                inverse ? inverse.map(&:inverse) : []
                              end
    end
  end
end
