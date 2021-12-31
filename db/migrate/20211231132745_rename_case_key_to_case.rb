class RenameCaseKeyToCase < ActiveRecord::Migration[6.1]
  def change
    rename_column :results, :case_key, :casee
  end
end
