require 'optparse'
require 'cube_trainer/anki/cube_visualizer'

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

    def on_cache
      on('-c', '--[no-]use-cache', 'Use a cache for fetches from the web.') do |c|
        @options.cache = c
      end
    end

    def on_size
      on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |s|
        @options.cube_size = s
      end
    end

    def on_output(file_description)
      on('-o', '--output [FILE]', String, 'Output path for the #{file_description}.') do |o|
        @options.output = o
      end
    end

    def on_stage_mask
      on('-m', '--stage_mask [MASK]', String, 'Stage mask to apply to all images, e.g. coll or cross-x2.') do |m|
        @options.stage_mask = CubeVisualizer::StageMask.parse(m)
      end
    end
    
  end
  
end
