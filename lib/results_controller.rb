require 'Qt4'
require 'results_model'
require 'result'

module CubeTrainer

  class ResultsController
  
    def initialize(table)
      @table = table
      @model = ResultsModel.new(:cubie_to_letter)
      @table.setRowCount(results.length)
      @table.setColumnCount(Result::COLUMNS)
      results.each_with_index { |r, i| set_result(i, r) }
    end
  
    def results
      @model.results
    end
  
    def record_result(result)
      @model.record_result(result)
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
