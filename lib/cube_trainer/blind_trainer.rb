# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/color_scheme'
require 'cube_trainer/cubie_controller'
require 'cube_trainer/letter_pair'
require 'cube_trainer/letter_scheme'
require 'cube_trainer/results_persistence'
require 'cube_trainer/stop_watch'
require 'cube_trainer/time_history'
require 'cube_trainer/ui_helpers'
require 'cube_trainer/ui/blind_trainer_ui'

module CubeTrainer
  class BlindTrainer < Qt::MainWindow
    slots 'start_stop_clicked()'

    include UiHelpers

    def start_stop_clicked
      if running?
        @stop_watch.stop
        start_stop_button.setText('Start')
      else
        start_stop_button.setText('Stop')
        start
      end
    end

    def start
      @failed_attempts = 0
      @cube_controller.select_cubie
      @stop_watch.start
    end

    def running?
      @stop_watch.running?
    end

    def event(e)
      if @initialized && running? && e.type == Qt::Event::KeyPress
        if e.text == @letter_scheme.letter(cubie)
          @stop_watch.stop
          @results_model.record_result(@stop_watch.current_time, create_partial_result, input)
          start
        elsif @letter_scheme.alphabet.include?(e.text)
          @failed_attempts += 1
        end
      end
      super(e)
    end

    def input
      LetterPair.new([@letter_scheme.letter(cubie)])
    end

    def start_stop_button
      @start_stop_button ||= find_child(Qt::PushButton, 'start_stop')
    end

    def create_partial_result
      PartialResult.new(@stop_watch.time_s, @failed_attempts, nil)
    end

    def cubie
      @cube_controller.cubie
    end

    # TODO: Find a better way to finalize the initialization.
    def init
      @letter_scheme = BernhardLetterScheme.new
      @color_scheme = ColorScheme::BERNHARD

      stop_watch_widget = find_child(Qt::Label, 'stop_watch')
      @stop_watch = StopWatch.new(stop_watch_widget)

      @results_model = ResultsModel.new(:cubie_to_letter, ResultsPersistence.create_for_production)

      time_history_widget = find_child(Qt::Widget, 'time_history')
      @time_history = TimeHistory.new(time_history_widget, @results_model)

      cube_view = find_child(Qt::GraphicsView, 'cube_view')
      @cube_controller = CubieController.new(cube_view, @color_scheme)

      @initialized = true
    end
  end
end
