# Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
# one twist case, one scramble etc.
# This represents the abstract case independent of its solution.
# For the specific case attached to a training session with a specific solution, see TrainingCase.
class Case
  include ActiveModel::Model

  attr_accessor :part_cycles

  def canonicalize
    @canonicalize ||= part_cycles.map(&:canonicalize).sort
  end

  def equivalent?(other)
    canonicalize == other.canonicalize
  end
end
