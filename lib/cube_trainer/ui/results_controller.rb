# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/result'
require 'cube_trainer/results_model'
require 'cube_trainer/results_persistence'

module CubeTrainer
  class ResultsController
    def initialize(table, model)
      @table = table
      @model = model
      reset
      @model.add_result_listener(self)
    end

    def reset
      @table.setRowCount(results.length)
      @table.setColumnCount(Result::COLUMNS)
      results.each_with_index { |r, i| set_result(i, r) }
    end

    def delete_after_time(_timestamp)
      reset
    end

    def results
      @model.results
    end

    def record_result(result)
      @table.insertRow(0)
      set_result(0, result)
    end

    def set_result(row, result)
      result.columns.each_with_index do |cell, col|
        item = Qt::TableWidgetItem.new(cell.to_s)
        @table.setItem(row, col, item)
      end
    end
  end
end
