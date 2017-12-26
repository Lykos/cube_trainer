require 'ui_helpers'
require 'console_helpers'

class HumanLearner
  include ConsoleHelpers
  include UiHelpers
  
  def initialize(hinter, results_model)
    @hinter = hinter
    @results_model = results_model
  end
  
  def execute(input)
    puts_and_say(input)
    data = time_before_any_key_press(@hinter.hint(input))
    if data.char == 'd'
      puts 'Pressed d. Deleting results for the last 10 seconds and exiting.'
      @results_model.delete_after_time(Time.now - 10)
      exit
    else
      puts "Time: #{format_time(data.time_s)}"
    end
    data.time_s
  end
end
