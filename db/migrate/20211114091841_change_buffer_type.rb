require 'twisty_puzzles'
require 'twisty_puzzles/utils'

class ChangeBufferType < ActiveRecord::Migration[6.0]
  class Mode < ApplicationRecord
    # TODO: Using a type here is bad because it might be deleted.
    attribute :mode_type, :training_session_type
  end

  class PartType
    extend TwistyPuzzles::Utils::StringHelper
    include TwistyPuzzles::Utils::StringHelper

    SEPARATOR = ':'
    PART_TYPE_NAME_TO_CLASS = TwistyPuzzles::PART_TYPES.index_by { |e| simple_class_name(e) }.freeze

    def cast(value)
      return if value.blank?
      return value if value.is_a?(TwistyPuzzles::Part)
      raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)
      raise ArgumentError, "Cannot determine part class of #{value}." unless value.to_s[SEPARATOR]

      raw_clazz, raw_data = value.split(SEPARATOR, 2)
      clazz = PART_TYPE_NAME_TO_CLASS[raw_clazz]
      raise ArgumentError, "Unknown part class #{raw_clazz}." unless clazz

      clazz.parse(raw_data)
    end

    def serialize(value)
      return if value.nil?

      value = cast(value) unless TwistyPuzzles::PART_TYPES.include?(value)
      "#{simple_class_name(value.class)}#{SEPARATOR}#{value}"
    end
  end

  def change
    rename_column :modes, :buffer, :old_buffer
    add_column :modes, :buffer, :string
    serializer = PartType.new
    reversible do |change|
      change.up do
        Mode.all.each do |mode|
          next if mode.old_buffer.blank?

          mode.update(buffer: serializer.serialize(mode.mode_type.part_type.parse(mode.old_buffer)))
        end
      end
      change.down do
        Mode.all.each do |mode|
          next unless mode.buffer

          mode.update(old_buffer: serializer.cast(mode.buffer).to_s)
        end
      end
    end
    remove_column :modes, :old_buffer, :string
  end
end
