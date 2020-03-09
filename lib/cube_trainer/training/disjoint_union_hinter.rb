# frozen_string_literal: true

require 'cube_trainer/training/restricted_hinter'

module CubeTrainer
  # Hinter that gives hint for the disjoint union of subhinters.
  class DisjointUnionHinter
    def initialize(restricted_hinters)
      restricted_hinters.each do |h|
        raise TypeError unless h.is_a?(RestrictedHinter)
      end
      restricted_hinters.combination(2).each do |r, s|
        overlap = r.inputs & s.inputs
        unless overlap.empty?
          raise "Letter pairs of different hinters overlap at #{overlap.join(', ')}."
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
      @restricted_hinters.collect_concat(&:entries)
    end
  end
end
