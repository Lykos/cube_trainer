require 'io/console'

module ConsoleHelpers

  def camel_to_snake(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  def espeak_processes
    @espeak_processes ||= {}
  end

  def espeak_process(language)
    espeak_processes[language] ||=
      IO.popen("espeak -v #{language} -s 120", 'w+')
  end
    
  def puts_and_say(stuff, language='de')
    puts stuff
    espeak_process(language).puts(stuff)
  end

  def wait_for_any_key
    exit if STDIN.getch == 'q'
  end

end
