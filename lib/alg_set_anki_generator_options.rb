require 'color_scheme'
require 'algorithm'
require 'parser'
require 'ostruct'
require 'common_options'

module CubeTrainer

  class AlgSetAnkiGeneratorOptions < CommonOptions

    def self.parse(args)
      AlgSetAnkiGeneratorOptions.new.parse(args)
    end

    def default_options
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.verbose = false
    end

    def add_options(opts, options)
      add_size(opts, options)
      add_output(opts, options)

      opts.on('-a', '--alg_set [ALG_SET]', String, 'Algorithm to be applied before visualization.') do |a|
        options.alg_set = a
      end
    end

  end

end
