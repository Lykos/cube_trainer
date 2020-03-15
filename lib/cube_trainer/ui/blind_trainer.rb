# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/color_scheme'
require 'cube_trainer/letter_pair'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/training/results_model'
require 'cube_trainer/training/results_persistence'
require 'cube_trainer/ui/cubie_controller'
require 'cube_trainer/ui/stop_watch_controller'
require 'cube_trainer/ui/time_history_controller'
require 'cube_trainer/ui/blind_trainer_ui'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Ui
    # Main window for the blind trainer.
    class BlindTrainer < Qt::MainWindow
      slots 'start_stop_clicked()'

      include Utils::StringHelper

      def start_stop_clicked
        if running?
          @stop_watch_controller.stop
          start_stop_button.setText('Start')
        else
          start_stop_button.setText('Stop')
          start
        end
      end

      def start
        @failed_attempts = 0
        @cube_controller.select_cubie
        @stop_watch_controller.start
      end

      def running?
        @stop_watch_controller.running?
      end

      def event(evt)
        if @initialized && running? && evt.type == Qt::Event::KeyPress
          if evt.text == @letter_scheme.letter(cubie)
            @stop_watch_controller.stop
            record_result
            start
          elsif @letter_scheme.alphabet.include?(evt.text)
            @failed_attempts += 1
          end
        end
        super(evt)
      end

      def input
        LetterPair.new([@letter_scheme.letter(cubie)])
      end

      def start_stop_button
        @start_stop_button ||= find_child(Qt::PushButton, 'start_stop')
      end

      def record_result
        @results_model.record_result(
          @stop_watch_controller.current_time,
          create_partial_result,
          input
        )
      end

      def create_partial_result
        Training::PartialResult.new(
          @stop_watch_controller.time_s,
          failed_attempts: @failed_attempts
        )
      end

      def cubie
        @cube_controller.cubie
      end

      # TODO: Find a better way to finalize the initialization.
      def init
        @letter_scheme = BernhardLetterScheme.new
        @color_scheme = ColorScheme::BERNHARD
        @results_model = Training::ResultsModel.new(
          :cubie_to_letter,
          Training::ResultsPersistence.create_for_production
        )

        @stop_watch_controller = create_stop_watch_controller
        @time_history_controller = create_time_history_controller
        @cube_controller = create_cubie_controller

        @initialized = true
      end

      private

      def create_stop_watch_controller
        widget = find_child(Qt::Label, 'stop_watch')
        StopWatchController.new(widget)
      end

      def create_time_history_controller
        widget = find_child(Qt::Widget, 'time_history')
        TimeHistoryController.new(widget, @results_model)
      end

      def create_cubie_controller
        widget = find_child(Qt::GraphicsView, 'cube_view')
        CubieController.new(widget, @color_scheme)
      end
    end
  end
end
