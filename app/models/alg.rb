# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/commutator_checker'
require 'twisty_puzzles'

# One alg that solves one particular case. E.g. the edge commutator [M', U2] for the case UF DF UB.
class Alg < ApplicationRecord
  include TwistyPuzzles

  belongs_to :alg_set
  attribute :case_key, :input_representation
  validates :alg, presence: true
  validates :case_key, presence: true
  validate :validate_case, :validate_buffer, :validate_alg

  # Cell description that we just make up without having an actual spreadsheet.
  class SyntheticCellDescription
    def initialize(part_cycle)
      @part_cycle = part_cycle
    end

    attr_reader :part_cycle

    delegate :to_s, to: :part_cycle
  end

  def buffer
    case_key.parts.first if case_key.is_a?(TwistyPuzzles::PartCycle)
  end

  def commutator
    parse_commutator(alg)
  end

  delegate :part_type, to: :case_key

  private

  def validate_case
    alg_set.mode_type.validate_case_key(case_key, errors)
  end

  def validate_buffer
    return unless alg_set.buffer

    errors.add(:case_key, 'case has an incorrect buffer') unless buffer == alg_set.buffer
  end

  # TODO: Make this work for other types of alg sets than commutators.
  def validate_alg
    comm =
      begin
        commutator
      rescue CommutatorParseError
        nil
      end

    unless comm
      errors.add(:alg, 'cannot be parsed as a commutator')
      return
    end

    checker = CommutatorChecker.new(
      part_type: part_type,
      cube_size: alg_set.mode_type.default_cube_size
    )
    return if checker.check_alg(SyntheticCellDescription.new(case_key), comm).result == :correct

    errors.add(:alg, 'is for the wrong case')
  end
end
