require 'Qt4'
require 'results_persistence'
require 'result'

class ResultsController

  def initialize(table)
    @table = table
    @result_persistence = ResultsPersistence.new
    @results = @result_persistence.load_results
    @table.setRowCount(@results.length)
    @table.setColumnCount(Result::COLUMNS)
    @results.each_with_index { |r, i| set_result(i, r) }
  end

  attr_reader :results

  def record_result(result)
    @results.unshift(result)
    @result_persistence.store_results(@results)
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
