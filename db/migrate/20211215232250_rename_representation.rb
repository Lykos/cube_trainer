class RenameRepresentation < ActiveRecord::Migration[6.0]
  def change
    rename_column :results, :representation, :case_key
  end
end
