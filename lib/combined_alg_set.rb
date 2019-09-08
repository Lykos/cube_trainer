require 'letter_pair_alg_set'

module CubeTrainer

  class CombinedLetterPairAlgSet < LetterPairAlgSet

    def initialize(results_model, options, *alg_sets)
      super
      @alg_sets = alg_sets
    end

    def hinter
      @hinter ||= CombinedHinter.new(@alg_sets.map { |a| RestrictedHinter.new(a.letter_pairs, a.hinter) })
    end

    def generate_letter_pairs
      @alg_sets.collect_concat { |a| a.letter_pairs }
    end

    def goal_badness
      @goal_badness ||= alg_sets.map { |a| a.goal_badness }.max
    end

  end

end
