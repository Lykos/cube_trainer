# coding: utf-8

require 'cube_trainer/move'
require 'cube_trainer/direction'
require 'cube_trainer/algorithm'
require 'cube_trainer/anki/cache'
require 'cube_trainer/anki/cube_visualizer'
require 'csv'
require 'parallel'
require 'cube_trainer/array_helper'
require 'cube_trainer/alg_hint_parser'
require 'net/http'

module CubeTrainer

  class AlgSetAnkiGenerator

    include ArrayHelper

    FORMAT = :jpg
    AUFS = [Algorithm.empty] + CubeDirection::NON_ZERO_DIRECTIONS.map { |d| Algorithm.move(FatMove.new(Face::U, d)) }
    
    def initialize(options)
      raise ArgumentError unless File.exist?(options.output) && File.directory?(options.output) && File.writable?(options.output)
      @options = options
      cache = options.cache ? Cache.new('cube_visualizer') : nil
      @visualizer = CubeVisualizer.new(Net::HTTP, cache, sch: options.color_scheme, fmt: FORMAT)
    end

    def hinter
      @hinter ||= AlgHintParser.maybe_parse_hints(@options.alg_set, @options.verbose)
    end


    def filename(name)
      File.join(@options.output, name)
    end

    def generate
      CSV.open(filename('deck.tsv'), 'wb', :col_sep => "\t") do |csv|
        generate_internal(csv)
      end
    end

    def aufs(alg)
      AUFS.map { |a| a + alg }
    end

    def algorithms
      algs = hinter.entries
      if @options.auf
        algs.collect_concat do |name, alg|
          AUFS.map.with_index { |auf, index| [name, auf + alg, index] }
        end
      else
        algs.map { |name, alg| [name, alg, 0] }
      end
    end

    # Make an alg name simple enough so we can use it as a file name without problems.
    # TODO This is broken
    def alg_file_name(name, variation)
      "alg_#{name}#{variation}.#{FORMAT}".gsub(/\s/, '_').gsub('ä', 'ae').gsub('ö', 'oe').gsub('ü', 'ue')
    end

    def img(source)
      raise ArgumentError, "Got bad filename #{source}" unless source =~ /^[\w.]+$/
      # TODO This is bad, but works with our restriction.
      "<img src='#{source}'/>"
    end
    
    def generate_internal(csv)
      Parallel.map(algorithms, progress: 'Fetching alg images', in_threads: 50) do |name, alg, variation|
        state = @options.color_scheme.solved_cube_state(@options.cube_size)
        basename = alg_file_name(name, variation)
        alg.inverse.apply_to(state)
        @visualizer.fetch_and_store(state, filename(basename))
        [name, alg, variation, basename]
      end.group_by { |l| l.first }.map do |name, stuff|
        alg = only(stuff.select { |name, alg, variation, basename| variation == 0 }.map { |name, alg, variation, basename| alg })
        csv << [name, alg] + stuff.map { |name, alg, variation, basename| img(basename) }
      end
    end
    
  end

end
