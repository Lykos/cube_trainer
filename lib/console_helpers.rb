require 'io/console'

module ConsoleHelpers

  # Minimum time until we accept the next input.
  MINIMUM_WAIT_TIME = 0.1

  def camel_to_snake(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  def espeak_processes
    @espeak_processes ||= {}
  end

  def espeak_process(language)
    espeak_processes[language] ||=
      IO.popen("espeak -v #{language} -s 160", 'w+')
  end
    
  def puts_and_say(stuff, language='de')
    puts stuff
    espeak_process(language).puts(stuff)
  end

  KeyPressWaitData = Struct.new(:char, :start, :time_s)

  HINT_SECONDS = 10

  # Exits in the case of character q.
  # Downcases the character before returning it.
  def time_before_any_key_press(hint=nil)
    # TODO Explain to the human what magic letters exist.
    start = Time.now
    char = nil
    hints = 0
    loop do
      char = STDIN.getch.downcase
      if char == 'h' && hint
        puts "#{HINT_SECONDS} time punishment added."
        puts hint
        hints += 1
      else
        break
      end
    end
    time_s = Time.now - start + hints * HINT_SECONDS
    if char == 'q'
      puts 'Pressed q. Exiting.'
      exit
    end
    KeyPressWaitData.new(char, start, time_s)
  end

end
