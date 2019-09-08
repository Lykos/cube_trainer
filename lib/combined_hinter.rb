require 'combined_hinter'

module CubeTrainer

  class RestrictedHinter

    def initialize(letter_pairs, hinter)
      @letter_pairs = letter_pairs
      @hinter = hinter
    end

    attr_reader :letter_pairs

    def hint(letter_pair)
      raise unless has_hint?(letter_pair)
      @hinter.hint(letter_pair)
    end

    def has_hint?(letter_pair)
      @letter_pairs.include?(letter_pair)
    end
  end

  class CombinedHinter

    def initialize(restricted_hinters)
      restricted_hinters.combination(2).each do |r, s|
        overlap = r.letter_pairs & s.letter_pairs
        if !overlap.empty?
          raise "Letter pairs of different hinters overlap at #{overlap.join(", ")}."
        end
      end
      @restricted_hinters = restricted_hinters
    end

    def hint(letter_pair)
      @restricted_hinters.each do |r|
        return r.hint(letter_pair) if r.has_hint?(letter_pair)
      end
      raise
    end
  end

end
