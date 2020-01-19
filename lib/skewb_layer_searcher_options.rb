require 'color_scheme'
require 'letter_scheme'
require 'optparse'
require 'ostruct'

module CubeTrainer

  class SkewbLayerSearcherOptions
    
    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
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

        opts.on('-l', '--[no-]layer-corners-as-letters', 'Show layer corners as letters instead of something like DRF.') do |l|
          options.layer_corners_as_letters = l
        end
        
        opts.on('-t', '--[no-]top-corners-as-letters', 'Show top corners as letters instead of something like URF.') do |t|
          options.top_corners_as_letters = t
        end
        
        opts.on('-n', '--name_file [FILE]', String, 'CSV file with a mapping from layer piece letter sequences to names.') do |n|
          options.name_file = n
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
