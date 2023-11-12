# frozen_string_literal: true

# One alg spreadsheet of a prominent blind solver.
# We extract alg sets from it.
# Typically there are multiple alg sets for each spreadsheet,
# usually one per sheet (aka tab).
class AlgSpreadsheet < ApplicationRecord
  has_many :alg_sets, dependent: :destroy
  has_many :sheet_runs, dependent: :destroy
  validates :owner, presence: true
  validates :spreadsheet_id, presence: true, uniqueness: true
end
