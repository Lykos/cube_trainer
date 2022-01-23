class AddInvertWingLetterToLetterScheme < ActiveRecord::Migration[6.1]
  def change
    add_column :letter_schemes, :invert_wing_letter, :boolean
  end
end
