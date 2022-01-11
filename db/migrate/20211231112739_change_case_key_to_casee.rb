class ChangeCaseKeyToCasee < ActiveRecord::Migration[6.1]
  def change
    rename_column :algs, :case_key, :casee
    rename_column :alg_overrides, :case_key, :casee
  end
end
