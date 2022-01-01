# frozen_string_literal: true

# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This contains a specific case attached to a training session with a specific solution.
# For the abstract case (independent of its solution), see Case.
class TrainingCase
  include ActiveModel::Model

  attr_accessor :casee, :training_session, :setup, :alg

  validates :casee, presence: true
  validates :training_session, presence: true

  def eql?(other)
    self.class.equal?(other.class) &&
      @training_session.id == other.training_session.id &&
      @casee == other.casee &&
      @alg == other.alg &&
      @setup == other.setup
  end

  alias == eql?

  def hash
    [self.class, @training_session.id, @case, @alg, @setup].hash
  end

  def to_simple
    {
      setup: setup.to_s,
      alg: alg.to_s,
      case_key: CaseType.new.serialize(casee),
      case_name: training_session.case_name(casee)
    }
  end
end
