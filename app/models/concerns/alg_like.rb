# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/case_checker'
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
    def initialize(part_cycle)
      @part_cycle = part_cycle
    end

    attr_reader :part_cycle

    delegate :to_s, to: :part_cycle
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
      casee: InputRepresentationType.new.serialize(casee),
      alg: alg.to_s
    }
  end

  private

  def validate_case
    return unless casee

    unless owning_set.case_set.match?(casee)
      errors.add(
        :casee,
        'does not belong to the case set of the alg set'
      )
    end
  end

  def commutator_or_nil
    commutator
  rescue CommutatorParseError
    nil
  end

  def create_checker
    CubeTrainer::CaseChecker.new(
      cube_size: owning_set.training_session_type.default_cube_size
    )
  end

  def alg_correct?(comm)
    create_checker.check_alg(SyntheticCellDescription.new(casee), comm).result == :correct
  end

  # TODO: Make this work for other types of alg sets than commutators.
  def validate_alg
    return unless casee.respond_to?(:part_type)
    return unless casee.part_type == owning_set.training_session_type.part_type

    comm = commutator_or_nil
    errors.add(:alg, 'cannot be parsed as a commutator') && return unless comm

    return if alg_correct?(comm)

    errors.add(:alg, 'does not solve this case')
  end
end
