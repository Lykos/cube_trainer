class AlgSpreadsheet < ApplicationRecord
  has_many :alg_sets
  validates :owner, presence: true
  validates :spreadsheet_id, presence: true
end
