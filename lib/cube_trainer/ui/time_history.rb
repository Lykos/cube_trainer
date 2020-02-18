# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/results_controller'
require 'cube_trainer/stats_model'

module CubeTrainer
  class TimeHistory
    def initialize(widget, results_model)
      @widget = widget

      @results_model = results_model

      results_table = widget.find_child(Qt::TableWidget, 'results_table')
      @results_controller = ResultsController.new(results_table, results_model)

      stats_table = widget.find_child(Qt::TableView, 'stats_table')
      @stats_model = StatsModel.new(results_model)
      stats_table.model = @stats_model
    end
  end
end
