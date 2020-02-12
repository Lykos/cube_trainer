# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/ui_helpers'
require 'cube_trainer/stats_computer'

module CubeTrainer
  class StatsModel < Qt::AbstractTableModel
    include UiHelpers

    def initialize
      super
      @computer = StatsComputer.new
      compute_stats([])
    end

    def compute_stats(results)
      @stats = @computer.compute_stats(results)
    end

    def format_stats(stats)
      stats.collect { |name, stat| [name, format_time(stat)] }
    end

    def recompute(results)
      @stats = format_stats(compute_stats(results))
      emit dataChanged(createIndex(0, 0), createIndex(1, @stats.length - 1))
    end

    def columnCount(_parent)
      2
    end

    def rowCount(_parent)
      @stats.length
    end

    def data(index, role)
      case role
      when Qt::DisplayRole
        row = index.row
        col = index.column
        Qt::Variant.new(@stats[row][col])
      else
        Qt::Variant.new
      end
    end
  end
end
