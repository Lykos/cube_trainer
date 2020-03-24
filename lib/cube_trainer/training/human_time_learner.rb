# frozen_string_literal: true

require 'cube_trainer/console_helpers'
require 'cube_trainer/core/cube_print_helper'
require 'cube_trainer/training/partial_result'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  module Training
    # Learner class that prints letter pairs to the console and has the human stop the time for
    # something.
    class HumanTimeLearner
      include ConsoleHelpers
      include Utils::StringHelper

      def initialize(hinter, results_model, options)
        @hinter = hinter
        @results_model = results_model
        @picture = options.picture
        @muted = options.muted
      end

      attr_reader :muted

      def handle_user_input_data(data)
        if data.char == 'd'
          puts 'Pressed d. Deleting results for the last 10 seconds and exiting.'
          @results_model.delete_after_time(Time.now - 10)
          exit
        else
          puts "Time: #{format_time(data.time_s)}"
        end
      end

      def execute(input)
        if @picture
          puts input.cube_state.colored_to_s
        else
          puts_and_say(input.representation)
        end
        data = time_before_any_key_press(@hinter.hints(input.representation))
        handle_user_input_data(data)
        PartialResult.new(data.time_s, num_hints: data.num_hints)
      end
    end
  end
end
