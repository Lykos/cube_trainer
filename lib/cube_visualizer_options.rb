require 'color_scheme'
require 'algorithm'
require 'parser'
require 'optparse'
require 'ostruct'

module CubeTrainer

  class CubeVisualizerOptions

    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.algorithm = Algorithm.empty
      opt_parser = OptionParser.new do |opts|
        opts.separator ''
        opts.separator 'Specific options:'      

        opts.on('-o', '--output [FILE]', String, 'Output path for the image file.') do |o|
          options.output = o
        end

        opts.on('-a', '--algorithm [ALGORITHM]', String, 'Algorithm to be applied before visualization.') do |a|
          options.algorithm = parse_algorithm(a)
        end

        opts.on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |size|
          options.cube_size = size
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
