require 'ui_helpers'
require 'console_helpers'
require 'result'

module CubeTrainer

  class HumanWordLearner
    include ConsoleHelpers
    include UiHelpers
    
    def initialize(hinter, results_model, options)
      @hinter = hinter
      @results_model = results_model
      @muted = options.muted
    end

    attr_reader :muted

    def display_hints(hints)
      if hints.length < 10
        puts_and_say(hints)
      else
        IO.popen('cat | less', 'w') do |io|
          io.puts(hints)
        end
      end
    end

    COMMANDS = ['hint', 'replace', 'delete', 'quit']
    
    def execute(input)
      puts_and_say(input)
      time_s = nil
      word = nil
      failed_attempts = 0
      start = Time.now
      until !word.nil? && @hinter.good_word?(input, word)
        if !word.nil? && !COMMANDS.include?(word)
          failed_attempts += 1
          if !input.matches_word?(word)
            puts_and_say('Bad word!', 'en')
          else
            puts_and_say('Incorrect!', 'en')
          end
        end
        last_word = word
        last_time_s = time_s
        last_failed_attempts = failed_attempts
        word = gets.chomp.downcase
        time_s = Time.now - start
        case word
        when 'hint'
          # Brutal punishment for failed attempts
          failed_attempts += 100
          hints = @hinter.hints(input.representation)
          display_hints(hints)
        when 'delete'
          puts 'Deleting results for the last 30 seconds and exiting.'
          @results_model.delete_after_time(Time.now - 30)
          exit          
        when 'replace'
          if last_word.nil? || COMMANDS.include?(last_word)
            puts_and_say('Can only replace with a valid word that is not a special command.')
          elsif input.matches_word?(last_word)
            raise if last_failed_attempts.nil? || last_time_s.nil?
            failed_attempts = last_failed_attempts
            word = last_word
            time_s = last_time_s
            puts_and_say('Replaced word.', 'en')
            break
          else
            puts_and_say('Cannot replace word with an invalid word.', 'en')
          end
        when 'quit'
          exit
        end
      end
      puts "Time: #{format_time(time_s)}; Failed attempts: #{failed_attempts}; Word: #{word}"
      PartialResult.new(time_s, failed_attempts, word)
    end
  end

end
