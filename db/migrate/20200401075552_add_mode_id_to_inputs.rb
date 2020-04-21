require 'cube_trainer/training/commutator_types'
require 'cube_trainer/buffer_helper'
require 'twisty_puzzles/utils'

class AddModeIdToInputs < ActiveRecord::Migration[6.0]
  include CubeTrainer::Training::CommutatorTypes

  class Input < ApplicationRecord
    attribute :old_mode, :symbol
    has_one :result, dependent: :destroy
  end

  COMMUTATOR_INFOS_BY_MODE_TYPE =
    COMMUTATOR_TYPES.values.map { |v| [v.result_symbol, v] }.to_h

  # Simplified version of the mode model. We can't use the proper
  # one because future validations and functionality would break this migration.
  class Mode < ApplicationRecord
    include TwistyPuzzles::Utils::ArrayHelper

    attribute :mode_type, :symbol
    attribute :show_input_mode, :symbol

    def picture
      show_input_mode == :picture
    end

    def letter_scheme
      @letter_scheme ||= CubeTrainer::BernhardLetterScheme.new
    end

    def color_scheme
      CubeTrainer::ColorScheme::BERNHARD
    end

    def legacy_mode
      CubeTrainer::BufferHelper.mode_for_options(self)
    end

    def commutator_info
      COMMUTATOR_INFOS_BY_MODE_TYPE[mode_type]
    end

    def generator
      commutator_info.generator_class.new(self)
    end
  end

  DEPRECATED_COMMUTATOR_TYPES = %i(corner_commutators cubie_to_letter edge_commutators floating_2twists_and_corner_3twists_pic letters_to_word xcenter_commutators old_letters_to_word)

  def extract_mode_params(old_mode)
    if DEPRECATED_COMMUTATOR_TYPES.include?(old_mode)
      return [nil, nil, nil]
    elsif info = COMMUTATOR_INFOS_BY_MODE_TYPE[old_mode]
      raise if info.has_buffer?
      return [nil, :name, old_mode]
    end
    parts = old_mode.to_s.split('_')
    if parts.length >= 3 && info = COMMUTATOR_INFOS_BY_MODE_TYPE[mode_name = parts[1..-2].join('_').to_sym]
      raise unless parts[-1] == 'pic'
      raise unless info.has_buffer?
      [parts[0].upcase.to_s, :picture, mode_name]
    elsif parts.length >= 2 && info = COMMUTATOR_INFOS_BY_MODE_TYPE[mode_name = parts[1..-1].join('_').to_sym]
      raise unless info.has_buffer?
      [parts[0].upcase.to_s, :name, mode_name]
    elsif parts.length >= 2 && info = COMMUTATOR_INFOS_BY_MODE_TYPE[mode_name = parts[0..-2].join('_').to_sym]
      raise if info.has_buffer?
      raise unless parts[-1] == 'pic'
      [nil, :picture, mode_name]
    else
      raise ArgumentError, "Couldn't translate old mode #{old_mode.inspect}."
    end
  end

  def add_mode_to_inputs
    modes = {}
    Input.reset_column_information
    Mode.reset_column_information
    Input.all.each do |r|
      mode_name = r.old_mode.to_s.gsub('_', ' ')
      buffer, show_input_mode, mode_type = extract_mode_params(r.old_mode)
      unless mode_type
        r.destroy!
        next
      end

      user_id = r.old_user_id
      mode = modes[[user_id, mode_name]] ||=
        begin
          mode = Mode.find_or_initialize_by(user_id: user_id, name: mode_name)
          mode.known = false
          mode.mode_type = mode_type
          mode.show_input_mode = show_input_mode
          mode.buffer = buffer
          mode.goal_badness = mode.generator.goal_badness if mode.generator.respond_to?(:goal_badness)
          mode.cube_size = mode.commutator_info.default_cube_size
          raise "Legacy mode #{mode.legacy_mode} not equal to old mode #{r.old_mode}." unless mode.legacy_mode == r.old_mode
          mode.save!
          mode
        end
      r.mode_id = mode.id
      r.save!
    end
  end
    
  def change
    rename_column :inputs, :mode, :old_mode
    rename_column :inputs, :user_id, :old_user_id
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
    change_column_null :inputs, :old_mode, true
    change_column_null :inputs, :old_user_id, true
  end
end
