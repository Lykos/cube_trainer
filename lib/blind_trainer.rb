require 'Qt4'
require 'stop_watch'
require 'time_history'
require 'blind_trainer_ui'
require 'cubie_controller'
require 'ui_helpers'

class BlindTrainer < Qt::MainWindow
  slots 'start_stop_clicked()'

  include UiHelpers

  def start_stop_clicked
    puts "LOL"
    if running?
      @stop_watch.stop
      start_stop_button.setText("Start")
    else
      puts "start"
      @cubie_controller.select_cubie
      @stop_watch.start
      start_stop_button.setText("Stop")
    end
  end

  def running?
    @stop_watch.running?
  end

  def event(e)
    if @initialized && running? && e.type == Qt::Event::KeyPress && e.text == cubie.letter
      @stop_watch.stop
      @time_history.record_result(create_result)
      @cubie_controller.select_cubie
      @stop_watch.start
    else
      super(e)
    end
  end

  def start_stop_button
    @start_stop_button ||= find_child(Qt::PushButton, 'start_stop')
  end

  def create_result
    Result.new(@stop_watch.start_time, @stop_watch.time_s, cubie)
  end

  def cubie
    @cubie_controller.cubie
  end

  # TODO Find a better way to finalize the initialization.
  def init
    stop_watch_widget = find_child(Qt::Label, 'stop_watch')
    @stop_watch = StopWatch.new(stop_watch_widget)

    time_history_widget = find_child(Qt::Widget, 'time_history') 
    @time_history = TimeHistory.new(time_history_widget)

    cubie_view = find_child(Qt::GraphicsView, 'cubie_view')
    @cubie_controller = CubieController.new(cubie_view)

    @initialized = true
  end

end
