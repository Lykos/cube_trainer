class ChangeBufferType < ActiveRecord::Migration[6.0]
  class Mode < ApplicationRecord
    attribute :mode_type, :mode_type
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
