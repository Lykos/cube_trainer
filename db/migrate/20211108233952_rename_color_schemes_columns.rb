class RenameColorSchemesColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column(:color_schemes, :U, :u)
    rename_column(:color_schemes, :F, :f)
    rename_column(:color_schemes, :R, :r)
    rename_column(:color_schemes, :L, :l)
    rename_column(:color_schemes, :B, :b)
    rename_column(:color_schemes, :D, :d)
    change_column_null(:color_schemes, :u, false)
    change_column_null(:color_schemes, :f, false)
    change_column_null(:color_schemes, :r, false)
    change_column_null(:color_schemes, :l, false)
    change_column_null(:color_schemes, :b, false)
    change_column_null(:color_schemes, :d, false)
  end
end
