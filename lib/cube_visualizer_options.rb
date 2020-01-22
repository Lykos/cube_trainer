require 'color_scheme'
require 'common_options'
require 'algorithm'
require 'parser'
require 'ostruct'

module CubeTrainer

  class CubeVisualizerOptions < CommonOptions

    def self.parse(args)
      CubeVisualizerOptions.new.parse(args)
    end

    def defaults
      options = OpenStruct.new
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.algorithm = Algorithm.empty
    end

    def add_options(opts, options)
      add_output(opts)
      add_size(opts)

      opts.on('-a', '--algorithm [ALGORITHM]', String, 'Algorithm to be applied before visualization.') do |a|
        options.algorithm = parse_algorithm(a)
      end
    end

  end

end
