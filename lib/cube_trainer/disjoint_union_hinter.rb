require 'cube_trainer/restricted_hinter'

module CubeTrainer

  # Hinter that gives hint for the disjoint union of subhinters.
  class DisjointUnionHinter

    def initialize(restricted_hinters)
      restricted_hinters.combination(2).each do |r, s|
        overlap = r.inputs & s.inputs
        if !overlap.empty?
          raise "Letter pairs of different hinters overlap at #{overlap.join(", ")}."
        end
      end
      @restricted_hinters = restricted_hinters
    end

    def hints(input)
      @restricted_hinters.each do |r|
        return r.hints(input) if r.in_domain?(input)
      end
      raise
    end
  end

end
