# frozen_string_literal: true

require 'cube_trainer/console_helpers'
require 'twisty_puzzles'
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

      def timed_getch(timeout_s)
        return STDIN.getch unless timeout_s

        begin
          Timeout.timeout(timeout_s) { STDIN.getch }
        rescue Timeout::Error
          nil
        end
      end

      # TODO: Explain special characters
      def wait_for_any_char(action_name: nil, timeout_s: nil)
        puts "Press any character to #{action_name}." if action_name
        char = timed_getch(timeout_s)
        case char
        when 'q'
          puts 'Quitting'
          exit(0)
        when 'd'
          puts 'Pressed d. Deleting results for the last 10 seconds and exiting.'
          @results_model.delete_after_time(Time.zone.now - 10)
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
        start = Time.zone.now
        puts "Max #{@memo_time_s} seconds to memo."
        if wait_for_any_char(action_name: 'start execution', timeout_s: @memo_time_s)
          time_s = Time.zone.now - start
          puts "Memo time: #{format_time(time_s)}"
        else
          puts_and_say('Go!', 'en')
          # If the human presses pretty much in the same moment we tell them to go,
          # assume it was a mistake and ignore the key press.
          # Nobody is ever going to have sub 1 execution anyway.
          wait_for_any_char(timeout_s: 0.5)
        end
      end

      def execute(input)
        scramble = input.representation
        raise TypeError unless scramble.is_a?(Core::Algorithm)

        puts scramble
        wait_for_any_char(action_name: 'start')
        start = Time.zone.now
        wait_for_memo_start
        wait_for_any_char(action_name: 'stop')
        time_s = Time.zone.now - start
        puts "Time: #{format_time(time_s)}"
        PartialResult.new(time_s: time_s, success: ask_success)
      end
    end
  end
end
