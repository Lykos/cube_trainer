class RemoveInputs < ActiveRecord::Migration[6.0]
  class Result < ApplicationRecord
  end

  class Input < ApplicationRecord
  end

  def change
    remove_index :results, column: :input_id, unique: true
    add_column :results, :representation, :string
    add_column :results, :mode_id, :integer
    add_index :results, :representation
    remove_foreign_key :results, :inputs
    remove_foreign_key :inputs, :modes
    Input.reset_column_information
    Result.reset_column_information
    reversible do |dir|
      dir.up do
        Result.all.each do |result|
          input = Input.find_by(id: result.input_id)
          result.update!(representation: input.input_representation, mode_id: input.mode_id)
        end
      end
      dir.down do
        Result.all.each do |result|
          input = Input.create!(input_representation: result.representation, mode_id: result.mode_id, created_at: result.created_at, updated_at: result.updated_at)
          result.update(input_id: input.id)
        end
      end
    end
    Input.reset_column_information
    Result.reset_column_information
    change_column_null :results, :input_id, true
    remove_column :results, :input_id, :integer
    change_column_null :results, :mode_id, false
    change_column_null :results, :representation, false
    add_foreign_key :results, :modes
    drop_table :inputs do |t|
      t.text :input_representation, null: false
      t.bigint :mode_id, null: false
      t.index :mode_id, name: :index_inputs_on_mode_id
      t.timestamps
    end
  end
end
