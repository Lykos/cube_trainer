require 'cube_trainer/training/commutator_types'

class AddModeIdToInputs < ActiveRecord::Migration[6.0]
  include CubeTrainer::Training::CommutatorTypes

  class Input < ApplicationRecord
  end

  class Mode < ApplicationRecord
  end

  def extract_mode_params(legacy_mode)
    if COMMUTATOR_TYPES.include?(legacy_mode)
      return [nil, nil, legacy_mode]
    end
    parts = legacy_mode.to_s.split('_')
    if parts.length >= 3 && COMMUTATOR_TYPES.include?(mode_name = parts[1..-2].join('_').to_sym)
      raise unless parts[-1] == 'pic'
      [parts[0].upcase.to_s, :picture, mode_name]
    elsif parts.length >= 2 && COMMUTATOR_TYPES.include?(mode_name = parts[1..-1].join('_').to_sym)
      [parts[0].upcase.to_s, :name, mode_name]
    elsif parts.length >= 2 && COMMUTATOR_TYPES.include?(mode_name = parts[0..-2].join('_').to_sym)
      raise unless parts[-1] == 'pic'
      [nil, :picture, mode_name]
    else
      raise ArgumentError, "Couldn't translate legacy mode #{legacy_mode.inspect}."
    end
  end

  def add_mode_to_inputs
    modes = {}
    Input.reset_column_information
    Mode.reset_column_information
    Input.all.each do |r|
      mode_name = r.legacy_mode.to_s.gsub('_', ' ')
      buffer, show_input_mode, mode_type = extract_mode_params(r.legacy_mode)
      user_id = r.legacy_user_id
      mode = modes[[user_id, mode_name]] ||=
        begin
          mode = Mode.find_or_initialize_by(user_id: user_id, name: mode_name)
          mode.known = false
          mode.mode_type = mode_type
          mode.show_input_mode = show_input_mode
          mode.buffer
          mode.goal_badness = mode.commutator_info.generator_class.new(mode).goal_badness
          mode.cube_size = mode.commutator_info.default_cube_size
          raise unless mode.legacy_mode == r.legacy_mode
          mode.save!
          mode
        end
      r.mode = mode
      r.save!
    end
  end
    
  def change
    rename_column :inputs, :mode, :legacy_mode
    rename_column :inputs, :user_id, :legacy_user_id
    add_reference :inputs, :mode, index: true, foreign_key: true
    reversible do |dir|
      dir.up do 
        add_mode_to_inputs
      end
      dir.down do
        # Nothing. The added data gets removed by the schema changes.
      end
    end
    change_column_null :inputs, :mode_id, false
    change_column_null :inputs, :legacy_mode, true
    change_column_null :inputs, :legacy_user_id, true
  end
end
