# frozen_string_literal: true

# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This contains a specific case attached to a training session with a specific solution.
# For the abstract case (independent of its solution), see Case.
class TrainingCase < ActiveModelSerializers::Model
  derive_attributes_from_names_and_fix_accessors
  attributes :casee, :training_session, :setup, :alg

  validates :casee, presence: true
  validates :training_session, presence: true
  alias owning_set training_session
  
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
end
