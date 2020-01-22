require 'cube_trainer/color_scheme'
require 'cube_trainer/algorithm'
require 'cube_trainer/parser'
require 'ostruct'
require 'cube_trainer/cube_trainer_options_parser'

module CubeTrainer

  class AlgSetAnkiGeneratorOptions

    def default_options
      options = OpenStruct.new
      # Default options
      options.color_scheme = ColorScheme::BERNHARD
      options.cube_size = 3
      options.verbose = false
      options
    end

    def self.parse(args)
      options = default_options
      
      CubeTrainerOptionsParser.new(options) do |opts|
        opts.on_size
        opts.on_output('anki deck & media output directory')

        opts.on('-a', '--alg_set [ALG_SET]', String, 'Algorithm to be applied before visualization.') do |a|
          options.alg_set = a
        end
      end.parse!(args)
      options
    end

  end

end
