class AddShortcutsToLetterSchemes < ActiveRecord::Migration[6.1]
  def change
    add_column :letter_schemes, :wing_lettering_mode, :string, null: false, default: :custom
    add_column :letter_schemes, :xcenters_like_corners, :boolean
    add_column :letter_schemes, :tcenters_like_edges, :boolean
    add_column :letter_schemes, :midges_like_edges, :boolean
  end
end
