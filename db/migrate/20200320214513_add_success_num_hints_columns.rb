# frozen_string_literal: true

class AddSuccessNumHintsColumns < ActiveRecord::Migration[5.0]
  def up
    add_column :Results, :success, :boolean, default: true
    add_column :Results, :num_hints, :integer, default: 0
  end

  def down
    remove_column :Results, :success
    remove_column :Results, :num_hints
  end
end
