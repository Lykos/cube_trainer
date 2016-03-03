require 'Qt4'
require 'results_controller'
require 'stats_model'
require 'ui_helpers'

class TimeHistory

  def initialize(widget)
    @widget = widget

    results_table = widget.find_child(Qt::TableWidget, 'results_table')
    @results_controller = ResultsController.new(results_table)

    stats_table = widget.find_child(Qt::TableView, 'stats_table')
    @stats_model = StatsModel.new
    stats_table.model = @stats_model
    recompute_stats
  end

  def recompute_stats
    @stats_model.recompute(@results_controller.results)
  end

  def record_result(result)
    @results_controller.record_result(result)
    recompute_stats
  end

end
