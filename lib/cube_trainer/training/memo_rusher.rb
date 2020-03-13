# frozen_string_literal: true

require 'cube_trainer/console_helpers'
require 'cube_trainer/core/algorithm'
require 'io/console'
require 'timeout'

module CubeTrainer
  module Training
    # Learner class for letting the human performing a memo rush on a given input scramble.
    class MemoRusher
      include ConsoleHelpers
      include Utils::StringHelper

      def initialize(_hinter, results_model, options)
        unless options.memo_time_s&.positive?
          raise ArgumentError, 'Argument memo_time_s has to be positive.'
        end

        @results_model = results_model
        @memo_time_s = options.memo_time_s
        @muted = options.muted
      end

      attr_reader :muted

      # TODO: Explain special characters
      def wait_for_any_char(action_name = nil)
        puts "Press any character to #{action_name}." if action_name
        char = STDIN.getch
        case char
        when 'q'
          puts 'Quitting'
          exit(0)
        when 'd'
          puts 'Pressed d. Deleting results for the last 10 seconds and exiting.'
          @results_model.delete_after_time(Time.now - 10)
          exit
        end
        char
      end

      def ask_success
        puts 'Success (y/n)?'
        answer = wait_for_any_char.downcase
        until %w[y n].include?(answer)
          puts 'y/n?'
          answer = wait_for_any_char.downcase
        end
        answer == 'y'
      end

      def wait_for_memo_start
        start = Time.now
        puts "Max #{@memo_time_s} seconds to memo."
        begin
          Timeout.timeout(@memo_time_s) { wait_for_any_char('start execution') }
          time_s = Time.now - start
          puts "Memo time: #{format_time(time_s)}"
        rescue Timeout::Error
          puts_and_say('Go!', 'en')
        end
      end

      def execute(input)
        scramble = input.representation
        raise TypeError unless scramble.is_a?(Core::Algorithm)

        puts scramble
        wait_for_any_char('start')
        start = Time.now
        wait_for_memo_start
        wait_for_any_char('stop')
        time_s = Time.now - start
        puts "Time: #{format_time(time_s)}"
        failed_attempts = ask_success ? 1 : 0
        PartialResult.new(time_s, failed_attempts, nil)
      end
    end
  end
end
