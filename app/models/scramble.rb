class Scramble
  include ActiveModel::Model

  attr_accessor :algorithm

  validates :algorithm, presence: true

  delegate :to_s, to: :algorithm
end
