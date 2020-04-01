require 'cube_trainer/training/commutator_types'

class AddInputIdToResults < ActiveRecord::Migration[6.0]
  include CubeTrainer::Training::CommutatorTypes

  class Result < ApplicationRecord
  end

  class Input < ApplicationRecord
  end

  def add_input_to_results
    inputs = {}
    Result.reset_column_information
    Input.reset_column_information
    Result.all.each do |r|
      user_id = r.old_user_id
      mode = r.old_mode
      input_representation = r.old_input_representation
      input =
        Input.new(
          user_id: user_id,
          mode: mode,
          input_representation: input_representation
        )
      input.hostname ||= r.old_hostname
      input.save!
      r.input_id = input.id
      r.save!
    end
  end

  def remove_inputs_without_hostname
    Input.reset_column_information
    Input.where(hostname: nil).destroy_all
  end

  def delete_non_old_data
    Result.where(old_user_id: nil).destroy_all
    Result.where(old_mode: nil).destroy_all
    Result.where(old_hostname: nil).destroy_all
    Result.where(old_input_representation: nil).destroy_all
  end

  def change
    add_column :inputs, :hostname, :string
    rename_column :results, :mode, :old_mode
    rename_column :results, :hostname, :old_hostname
    rename_column :results, :user_id, :old_user_id
    rename_column :results, :input_representation, :old_input_representation
    add_reference :results, :input, index: { unique: true }, foreign_key: true
    reversible do |dir|
      dir.up do 
        add_input_to_results
        remove_inputs_without_hostname
      end
      dir.down do
        # Nothing. The added data gets removed by the schema changes.
      end
    end
    change_column_null :inputs, :hostname, false
    change_column_null :results, :input_id, false
    change_column_null :results, :old_mode, true
    change_column_null :results, :old_hostname, true
    change_column_null :results, :old_user_id, true
    change_column_null :results, :old_input_representation, true

    reversible do |dir|
      dir.up {}
      dir.down do
        delete_non_old_data
      end
    end
  end
end
