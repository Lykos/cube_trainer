# frozen_string_literal: true

require 'io/console'

module CubeTrainer
  # Helper functions to interact with a user on the command line.
  module ConsoleHelpers
    # Minimum time until we accept the next input.
    MINIMUM_WAIT_TIME = 0.1

    def espeak_processes
      @espeak_processes ||= {}
    end

    def espeak_process(language)
      espeak_processes[language] ||=
        IO.popen("espeak -v #{language} -s 160", 'w+')
    end

    def say(stuff, language)
      espeak_process(language).puts(stuff) unless muted
    end

    def puts_and_say(stuff, language = 'de')
      puts stuff
      say(stuff, language)
    end

    KeyPressWaitData = Struct.new(:char, :time_s, :num_hints)

    #  Minimum time s.t. it is not considered an accidental double click.
    MIN_SECONDS = 0.05

    # Exits in the case of character q.
    # Downcases the character before returning it.
    # rubocop:disable Metrics/MethodLength
    def time_before_any_key_press(hints = [])
      # TODO: Explain to the human what magic letters exist.
      start = Time.zone.now
      char = nil
      num_hints = 0
      loop do
        char = $stdin.getch.downcase
        if char == 'h'
          if hints.length > num_hints
            puts hints[num_hints]
            num_hints += 1
          else
            puts 'No hint available.'
          end
        elsif Time.zone.now - start >= MIN_SECONDS
          break
        end
      end
      time_s = Time.zone.now - start
      if char == 'q'
        puts 'Pressed q. Exiting.'
        exit
      end
      KeyPressWaitData.new(char, time_s, num_hints)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
