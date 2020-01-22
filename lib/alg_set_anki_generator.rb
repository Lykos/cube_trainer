# coding: utf-8

require 'move'
require 'direction'
require 'algorithm'
require 'cube_visualizer'
require 'csv'
require 'parallel'
require 'alg_hint_parser'
require 'zip'

module CubeTrainer

  class AlgSetAnkiGenerator

    FORMAT = :jpg
    AUFS = CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Algorithm.move(FatMove.new(Face::U, d)) }
    
    def initialize(options)
      raise ArgumentError unless File.exist?(options.output) && File.directory?(options.output) && File.writable?(options.output)
      @options = options
      @visualizer = CubeVisualizer.new(sch: options.color_scheme, fmt: FORMAT)
    end

    def hinter
      @hinter ||= AlgHintParser.maybe_parse_hints(@options.alg_set, @options.verbose)
    end

    def algorithms
      hinter.entries.collect_concat do |name, alg|
        [[name, alg]] + AUFS.map { |auf| [AlgName.new(auf.to_s + ' ' + name.to_s), auf + alg] }
      end
    end

    def filename(name)
      File.join(@options.output, name)
    end

    def generate
      CSV.open(filename('deck.tsv'), 'wb', :col_sep => "\t") do |csv|
        generate_internal(csv)
      end
    end
    
    def generate_internal(csv)
      state = @options.color_scheme.solved_cube_state(@options.cube_size)
      Parallel.each(algorithms, progress: 'Fetching alg images', in_threads: 50) do |name, alg|
        basename = "#{name}.#{FORMAT}".gsub(/\s/, '_').gsub(/'/, '-').gsub('ä', 'ae')
        csv << [name, alg, "<img src='#{basename}'/>"]
        alg.inverse.apply_temporarily_to(state) do
          @visualizer.fetch_and_store(state, filename(basename))
        end
      end
    end
    
  end

end
