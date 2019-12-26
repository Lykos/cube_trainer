require 'ui_helpers'
require 'console_helpers'
require 'result'
require 'cube_print_helper'

module CubeTrainer

  class HumanTimeLearner
    include ConsoleHelpers
    include UiHelpers
    include CubePrintHelper
    
    def initialize(hinter, results_model, options)
      @hinter = hinter
      @results_model = results_model
      @picture = options.picture
      @muted = options.muted
    end

    attr_reader :muted
    
    def execute(input)
      if @picture
        puts cube_string(input.cube_state, :color)
      else
        puts_and_say(input.representation)
      end
      data = time_before_any_key_press(@hinter.hints(input.representation))
      if data.char == 'd'
        puts 'Pressed d. Deleting results for the last 10 seconds and exiting.'
        @results_model.delete_after_time(Time.now - 10)
        exit
      else
        puts "Time: #{format_time(data.time_s)}"
      end
      PartialResult.new(data.time_s, 0, nil)
    end
  end

end
