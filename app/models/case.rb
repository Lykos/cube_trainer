# frozen_string_literal: true

# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
class Case
  include ActiveModel::Model

  attr_accessor :case_key, :training_session, :setup, :alg, :representation

  validates :case_key, presence: true
  validates :training_session, presence: true

  def to_simple
    {
      setup: setup.to_s,
      alg: alg.to_s,
      case_key: InputRepresentationType.new.serialize(case_key),
      case_name: training_session.maybe_apply_letter_scheme(case_key).to_s
    }
  end
end
