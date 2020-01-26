require 'cube_trainer/restricted_hinter'

module CubeTrainer

  # Hinter that gives hint for the disjoint union of subhinters.
  class DisjointUnionHinter

    def initialize(restricted_hinters)
      restricted_hinters.each do |h|
        raise TypeError unless h.respond_to?(:in_domain?) && h.respond_to?(:hints) && h.respond_to?(:entries)
      end
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

    def entries
      @restricted_hinters.collect_concat { |h| h.entries }
    end
  end

end
