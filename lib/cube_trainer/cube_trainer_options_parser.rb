require 'optparse'

module CubeTrainer

  class CubeTrainerOptionsParser < OptionParser

    def initialize(options, &block)
      @options = options
      super do |opts|
        opts.separator ''
        opts.separator 'Specific options:'

        yield opts
        
        opts.on('-v', '--[no-]verbose', 'Give more verbose information.') do |v|
          options.verbose = v
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end
    end

    def on_size
      on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |s|
        @options.cube_size = s
      end
    end

    def on_output(file_description)
      opts.on('-o', '--output [FILE]', String, 'Output path for the #{file_description}.') do |o|
        @options.output = o
      end
    end
    
  end
  
end
