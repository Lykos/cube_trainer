require 'ostruct'
require 'common_options'
require 'color_scheme'

module CubeTrainer

  class SkewbLayerFinderOptions < CommonOptions
    
    def self.parse(args)
      SkewbLayerFinderOptions.new.parse(args)
    end
    
    def default_options
      options = OpenStruct.new
      options.color_scheme = ColorScheme::BERNHARD
    end

    def add_options(opts, options)
      opts.on('-x', '--restrict_colors COLORLIST', /[yrbgow]+/, 'Restrict colors to find a layer for.') do |colors|
        options.restrict_colors = colors.each_char.collect { |c| options.color_scheme.colors.find { |o| o.to_s[0] == c } }
      end
    end
  end

end
