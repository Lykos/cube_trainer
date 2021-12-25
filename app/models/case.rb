# frozen_string_literal: true

# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
class Case
  include ActiveModel::Model

  attr_accessor :mode, :setup, :alg, :representation

  validates :case_key, presence: true
  validates :mode, presence: true

  def to_simple
    {
      setup: setup.to_s,
      alg: alg.to_s,
      case_key: InputRepresentationType.new.serialize(case_key),
      case_name: mode.maybe_apply_letter_scheme(case_key).to_s
    }
  end
end
