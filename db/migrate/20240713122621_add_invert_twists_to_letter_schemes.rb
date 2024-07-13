class AddInvertTwistsToLetterSchemes < ActiveRecord::Migration[7.1]
  def change
    add_column :letter_schemes, :invert_twists, :boolean
  end
end
