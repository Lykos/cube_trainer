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

  # Exits in the case of character q.
  def wait_for_any_key
    if @last_time
      sleep(@last_time + MINIMUM_WAIT_TIME - Time.now)
    end
    char = STDIN.getch
    @last_time = Time.now
    if char.downcase == 'q'
      puts 'Pressed q. Exiting.'
      exit
    end
    char
  end

end
