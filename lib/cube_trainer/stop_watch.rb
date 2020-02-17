# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/ui_helpers'

module CubeTrainer
  class StopWatch < Qt::Object
    slots 'start()', 'stop()', 'update()'

    include UiHelpers

    def initialize(widget)
      super
      @widget = widget
      @time_ms = 0
      timer = Qt::Timer.new(widget)
      connect(timer, SIGNAL('timeout()'), self, SLOT('update()'))
      timer.start(0)
    end

    attr_reader :running, :start_time

    def running?
      @running
    end

    def elapsed_time_s
      current_time - @start_time
    end

    def current_time
      Time.now
    end

    def time_s
      if @running
        elapsed_time_s
      else
        @time_s
      end
    end

    def update
      display_time if @running
    end

    def start
      @start_time = current_time
      @running = true
    end

    def stop
      @time_s = elapsed_time_s
      @running = false
    end

    def display_time
      @widget.setText(format_time(time_s))
    end
  end
end
