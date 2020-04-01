require 'cube_trainer/training/commutator_types'

class AddInputIdToResults < ActiveRecord::Migration[6.0]
  include CubeTrainer::Training::CommutatorTypes

  def add_input_to_results
    inputs = {}
    Result.all.each do |r|
      user_id = r.legacy_user_id
      mode = r.legacy_mode
      input_representation = r.legacy_input_representation
      input = inputs[[user_id, mode, input_representation]] ||=
        begin
          input = Input.find_or_initialize_by(user_id: user_id, mode: mode, input_representation: input_representation)
          input.hostname ||= r.legacy_hostname
          input.save(validate: false)
          input
        end
      r.input = input
      r.save!
    end
  end

  def remove_inputs_without_hostname
    Input.where(hostname: nil).destroy_all
  end

  def change
    add_column :inputs, :hostname, :string
    rename_column :results, :mode, :legacy_mode
    rename_column :results, :hostname, :legacy_hostname
    rename_column :results, :user_id, :legacy_user_id
    rename_column :results, :input_representation, :legacy_input_representation
    add_reference :results, :input, index: { unique: true }, foreign_key: true
    reversible do |dir|
      dir.up do 
        add_input_to_results
        remove_inputs_without_hostname
      end
      dir.down do
        # Nothing the added columns die anyway.
      end
    end
    change_column_null :inputs, :hostname, false
    change_column_null :results, :input_id, false
    change_column_null :results, :legacy_mode, true
    change_column_null :results, :legacy_hostname, true
    change_column_null :results, :legacy_user_id, true
    change_column_null :results, :legacy_input_representation, true
  end
end
