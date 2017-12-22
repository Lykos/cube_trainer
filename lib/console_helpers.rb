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

  # Exits in the case of character q.
  def time_before_any_key_press
    start = Time.now
    char = STDIN.getch
    time = Time.now - start
    if char.downcase == 'q'
      puts 'Pressed q. Exiting.'
      exit
    end
    KeyPressWaitData.new(char, start, time)
  end

end
