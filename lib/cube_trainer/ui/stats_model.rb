# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/native'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  class StatsModel < Qt::AbstractTableModel
    include Utils::StringHelper

    AVERAGE_SIZES = [5, 12, 50, 100, 1000].freeze

    def initialize(results_model)
      super()
      @results_model = results_model
      reset
      @results_model.add_result_listener(self)
    end

    def reset
      @averages = AVERAGE_SIZES.map { |s| Native::CubeAverage.new(s, 0.0) }
      @results_model.results.each { |r| push_result(r) }
      emit dataChanged(createIndex(0, 0), createIndex(1, @averages.length - 1))
    end

    def push_result(result)
      @averages.each { |a| a.push(result.time_s) }
    end

    def delete_after_time(_timestamp)
      reset
    end

    def record_result(result)
      push_result(result)
      emit dataChanged(createIndex(0, 0), createIndex(1, @averages.length - 1))
    end

    def format_stats(stats)
      stats.collect { |name, stat| [name, format_time(stat)] }
    end

    def columnCount(_parent)
      2
    end

    def rowCount(_parent)
      @averages.length
    end

    def data(index, role)
      case role
      when Qt::DisplayRole
        row = index.row
        col = index.column
        case col
        when 0 then Qt::Variant.new("average of #{@averages[row].capacity}")
        when 1 then Qt::Variant.new(@averages[row].average)
        else raise ArgumentError
        end
      else
        Qt::Variant.new
      end
    end
  end
end
