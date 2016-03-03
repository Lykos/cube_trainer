require 'Qt4'
require 'ui_helpers'

class StatsModel < Qt::AbstractTableModel

  include UiHelpers

  attr_reader :results

  def initialize
    super
    compute_stats([])
  end

  def compute_stats(results)
    @stats = [
              ['Average Overall', compute_average(results)],
             ]
  end

  def compute_average(results)
    average(float_times_ms(results))
  end

  def average(values)
    values.inject(0.0, :+) / values.length
  end

  def float_times_ms(results)
    results.collect { |result| result.time_s }
  end

  def format_stats(stats)
    stats.collect { |name, stat| [name, format_time(stat)] }
  end

  def recompute(results)
    @stats = format_stats(compute_stats(results))
    emit dataChanged(createIndex(0, 0), createIndex(1, @stats.length - 1))
  end

  def columnCount(parent)
    2
  end

  def rowCount(parent)
    @stats.length
  end

  def data(index, role)
    return case role
           when Qt::DisplayRole
             row, col = index.row, index.column
             Qt::Variant.new(@stats[row][col])
           else
             Qt::Variant.new
           end
  end

end
