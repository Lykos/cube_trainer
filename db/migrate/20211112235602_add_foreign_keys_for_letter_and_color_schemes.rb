class AddForeignKeysForLetterAndColorSchemes < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :letter_schemes, :users
    add_foreign_key :letter_scheme_mappings, :letter_schemes
  end
end
