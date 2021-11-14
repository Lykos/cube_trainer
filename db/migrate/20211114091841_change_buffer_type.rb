class ChangeBufferType < ActiveRecord::Migration[6.0]
  def change
    rename_column :modes, :buffer, :old_buffer
    add_column :modes, :buffer, :string
    reversible do |change|
      change.up do
        serializer = PartType.new
        Mode.all.each do |mode|
          next if mode.old_buffer.blank?

          mode.update(buffer: serializer.serialize(mode.part_type.parse(mode.old_buffer)))
        end
      end
      change.down do
        Mode.all.each do |mode|
          next unless mode.buffer

          puts mode.buffer
          mode.update(old_buffer: mode.buffer.to_s)
        end
      end
    end
    remove_column :modes, :old_buffer, :string
  end
end
