class AddParityParts < ActiveRecord::Migration[6.0]
  def change
    add_column :modes, :first_parity_part, :string
    add_column :modes, :second_parity_part, :string
  end
end
