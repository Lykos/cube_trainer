# frozen_string_literal: true

class AddSuccessNumHintsColumns < ActiveRecord::Migration[5.0]
  def up
    add_column :Results, :Success, :boolean, default: true
    add_column :Results, :NumHints, :integer, default: 0
  end

  def down
    remove_column :Results, :Success
    remove_column :Results, :NumHints
  end
end
