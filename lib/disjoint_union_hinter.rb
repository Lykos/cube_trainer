module CubeTrainer

  class RestrictedHinter

    def initialize(letter_pairs, hinter)
      @letter_pairs = letter_pairs
      @hinter = hinter
    end

    attr_reader :letter_pairs

    def hints(letter_pair)
      raise unless in_domain?(letter_pair)
      @hinter.hints(letter_pair)
    end

    def in_domain?(letter_pair)
      @letter_pairs.include?(letter_pair)
    end
  end

  # Hinter that gives hint for the disjoint union of subhinters.
  class DisjointUnionHinter

    def initialize(restricted_hinters)
      restricted_hinters.combination(2).each do |r, s|
        overlap = r.letter_pairs & s.letter_pairs
        if !overlap.empty?
          raise "Letter pairs of different hinters overlap at #{overlap.join(", ")}."
        end
      end
      @restricted_hinters = restricted_hinters
    end

    def hints(letter_pair)
      @restricted_hinters.each do |r|
        return r.hints(letter_pair) if r.in_domain?(letter_pair)
      end
      raise
    end
  end

end
