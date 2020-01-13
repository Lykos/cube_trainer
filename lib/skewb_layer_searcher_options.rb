require 'letter_scheme'
require 'optparse'
require 'ostruct'

module CubeTrainer

  class SkewbLayerSearcherOptions
    
    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.verbose = true
      options.letter_scheme = DefaultLetterScheme.new
      opt_parser = OptionParser.new do |opts|
        opts.separator ''
        opts.separator 'Specific options:'      

        opts.on('-o', '--output [FILE]', String, 'Output path for a TSV file with the Skewb layers.') do |o|
          options.output = o
        end
        
        opts.on('-v', '--[no-]verbose', 'Give more verbose information.') do |v|
          options.verbose = v
        end

        opts.on('-d', '--depth [DEPTH]', Integer, 'Maximum search depth. Infinite if this is not set.') do |d|
          options.depth = d
        end
        
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end   
      end
      opt_parser.parse!(args)
      options
    end
  end

end
