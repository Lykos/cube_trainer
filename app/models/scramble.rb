# frozen_string_literal: true

# A scramble consisting of an algorithm (i.e. a sequence of moves) that should
# be applied to a solved puzzle to get it to a scrambled state.
class Scramble
  include ActiveModel::Model

  attr_accessor :algorithm

  validates :algorithm, presence: true

  delegate :to_s, to: :algorithm
end
