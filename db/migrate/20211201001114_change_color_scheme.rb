class ChangeColorScheme < ActiveRecord::Migration[6.0]
  class ColorScheme < ApplicationRecord
  end

  def change
    change_table :color_schemes do |t|
      t.rename :u, :color_u
      t.rename :f, :color_f
      t.remove :r
      t.remove :b
      t.remove :l
      t.remove :d
    end

    reversible do |dir|
      dir.up do
        ColorScheme.reset_column_information
        ColorScheme.all.each do |c|
          c.update(color_u: c.color_u.downcase, color_f: c.color_f.downcase)
        end
      end
    end
  end
end
