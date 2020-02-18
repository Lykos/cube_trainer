# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/native'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Ui
    # Model for statistics about the times that are displayed.
    class StatsModel < Qt::AbstractTableModel
      include Utils::StringHelper

      AVERAGE_SIZES = [5, 12, 50, 100, 1000].freeze

      def initialize(results_model)
        super()
        @results_model = results_model
        reset
        @results_model.add_result_listener(self)
      end

      def saturated_averages
        @averages.find_index { |a| !a.saturated? } || @averages.length
      end

      def emit_data_changed
        emit dataChanged(createIndex(0, 0), createIndex(1, saturated_averages - 1))
      end

      def reset
        @averages = AVERAGE_SIZES.map { |s| Native::CubeAverage.new(s, 0.0) }
        @results_model.results.each { |r| push_result(r) }
        emit_data_changed
      end

      def push_result(result)
        @averages.each { |a| a.push(result.time_s) }
      end

      def delete_after_time(_timestamp)
        reset
      end

      def record_result(result)
        push_result(result)
        emit_data_changed
      end

      def format_stats(stats)
        stats.collect { |name, stat| [name, format_time(stat)] }
      end

      # rubocop:disable Naming/MethodName
      def columnCount(_parent)
        2
      end

      def rowCount(_parent)
        saturated_averages
      end
      # rubocop:enable Naming/MethodName

      def displayable_data_at(row, col)
        case col
        when 0 then Qt::Variant.new("average of #{@averages[row].capacity}")
        when 1 then Qt::Variant.new(@averages[row].average)
        else raise ArgumentError
        end
      end

      def data(index, role)
        case role
        when Qt::DisplayRole
          displayable_data_at(index.row, index.column)
        else
          Qt::Variant.new
        end
      end
    end
  end
end
