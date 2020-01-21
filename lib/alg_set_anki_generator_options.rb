require 'color_scheme'
require 'algorithm'
require 'parser'
require 'optparse'
require 'ostruct'

module CubeTrainer

  class AlgSetAnkiGeneratorOptions

    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.verbose = false
      opt_parser = OptionParser.new do |opts|
        opts.separator ''
        opts.separator 'Specific options:'      

        opts.on('-o', '--output [FILE]', String, 'Output path for the anki zip file.') do |o|
          options.output = o
        end

        opts.on('-a', '--alg_set [ALG_SET]', String, 'Algorithm to be applied before visualization.') do |a|
          options.alg_set = a
        end

        opts.on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |size|
          options.cube_size = size
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end   

        opts.on('-v', '--[no-]verbose', 'Give more verbose information.') do |v|
          options.verbose = v
        end
      end
      opt_parser.parse!(args)
      options
    end

  end

end
