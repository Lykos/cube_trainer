class Alg < ApplicationRecord
  belongs_to :alg_set
  validates :alg, presence: true
  validates :case_key, presence: true
end
