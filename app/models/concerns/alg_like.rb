# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/case_checker'
require 'cube_trainer/training/case_pattern'
require 'twisty_puzzles'

# Concern for classes that behave like and alg that solves
# one particular case. E.g. the edge commutator [M', U2] for the case UF DF UB.
module AlgLike
  include TwistyPuzzles
  extend ActiveSupport::Concern

  included do
    attribute :casee, :case
    validates :alg, presence: true
    validates :casee, presence: true
    validate :validate_case, :validate_alg
  end

  # Cell description that we just make up without having an actual spreadsheet.
  class SyntheticCellDescription
    def initialize(casee)
      @pattern = CubeTrainer::Training::SpecificCasePattern.new(casee)
    end

    attr_reader :pattern

    delegate :to_s, to: :pattern
  end

  def commutator
    alg && parse_commutator(alg)
  end

  def owning_set
    raise NotImplementedError
  end

  def to_simple
    {
      id: id,
      case_key: CaseType.new.serialize(casee),
      case_name: owning_set.case_name(casee),
      alg: alg.to_s
    }
  end

  private

  def validate_case
    return unless casee

    unless casee.valid?
      errors.add(:casee, 'needs to be valid')
      return
    end
    unless owning_set.case_set.match?(casee)
      errors.add(:casee, 'does not belong to the case set of the alg set')
      return
    end
    return if owning_set.case_set.strict_match?(casee)

    errors.add(:casee, 'does not have the right form for the case set of the alg set')
  end

  def commutator_or_nil
    commutator
  rescue CommutatorParseError
    nil
  end

  def create_checker
    CubeTrainer::CaseChecker.new(
      cube_size: owning_set.case_set.default_cube_size
    )
  end

  def alg_correct?(comm)
    create_checker.check_alg(SyntheticCellDescription.new(casee), comm).correct?
  end

  def validate_alg
    return unless casee.is_a?(Case)

    comm = commutator_or_nil
    unless comm
      errors.add(:alg, 'cannot be parsed as a commutator')
      return
    end

    return if alg_correct?(comm)

    errors.add(:alg, 'does not solve this case')
  end
end
