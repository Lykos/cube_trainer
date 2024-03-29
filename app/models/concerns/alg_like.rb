# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/case_reverse_engineer'
require 'twisty_puzzles'

# Concern for classes that behave like and alg that solves
# one particular case. E.g. the edge commutator [M', U2] for the case UF DF UB.
module AlgLike
  include TwistyPuzzles
  extend ActiveSupport::Concern

  included do
    attr_accessor :is_inferred
    attr_writer :inverse

    attribute :casee, :case
    validates :alg, presence: true
    validates :casee, presence: true
    validate :validate_case, :validate_alg
    delegate :algorithm, to: :commutator
  end

  def commutator
    alg && parse_commutator(alg)
  end

  def owning_set
    raise NotImplementedError
  end

  def inverse
    @inverse ||=
      begin
        result = dup
        result.is_inferred = true
        result.alg = commutator.inverse.to_s
        result.inverse = self
        result
      end
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

  # Seems like this should be cached, but really it's only created multiple
  # times during scraping where latency doesn't matter.
  def create_reverse_engineer
    CubeTrainer::CaseReverseEngineer.new(
      cube_size: owning_set.case_set.default_cube_size
    )
  end

  def validate_alg
    return unless casee.is_a?(Case)

    comm = commutator_or_nil
    unless comm
      errors.add(:alg, 'cannot be parsed as a commutator')
      return
    end

    found_case = create_reverse_engineer.find_case(comm.algorithm)
    unless found_case
      errors.add(:alg, unsuitable_cube_size_message(comm))
      return
    end

    return if found_case.equivalent?(casee)

    errors.add(:alg, incorrect_case_message(comm, found_case))
  end

  def incorrect_case_message(comm, found_case)
    if owning_set.case_set.match?(found_case)
      "#{comm} does not solve case #{owning_set.raw_case_name(casee)} " \
        "but case #{owning_set.raw_case_name(found_case)}"
    else
      "#{comm} does not solve case #{owning_set.raw_case_name(casee)} " \
        'but does not belong to the alg set.'
    end
  end

  def unsuitable_cube_size_message(comm)
    "#{comm} does not seem to be suitable for cube size " \
      "#{owning_set.case_set.default_cube_size}"
  end
end
