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
    if running?
      @stop_watch.stop
      start_stop_button.setText("Start")
    else
      start_stop_button.setText("Stop")
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
      if e.text == cubie.letter
        @stop_watch.stop
        @time_history.record_result(create_result)
        start
      elsif ALPHABET.include?(e.text)
        @failed_attempts += 1
      end
    end
    super(e)
  end

  def start_stop_button
    @start_stop_button ||= find_child(Qt::PushButton, 'start_stop')
  end

  def create_result
    raise NotImplementedError, "This doesn't work after we changed the format of the result: Result.new(@stop_watch.start_time, @stop_watch.time_s, cubie, @failed_attempts)"
  end

  def cubie
    @cube_controller.cubie
  end

  # TODO Find a better way to finalize the initialization.
  def init
    stop_watch_widget = find_child(Qt::Label, 'stop_watch')
    @stop_watch = StopWatch.new(stop_watch_widget)

    time_history_widget = find_child(Qt::Widget, 'time_history') 
    @time_history = TimeHistory.new(time_history_widget)

    cube_view = find_child(Qt::GraphicsView, 'cube_view')
    @cube_controller = CubieController.new(cube_view)

    @initialized = true
  end

end
