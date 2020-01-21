require 'cube_visualizer'
require 'csv'
require 'alg_hint_parser'
require 'zip'

module CubeTrainer

  class AlgSetAnkiGenerator

    FORMAT = :jpg
    
    def initialize(options)
      raise ArgumentError unless options.output.end_with?('.zip')
      @options = options
      @visualizer = CubeVisualizer.new(sch: options.color_scheme, fmt: FORMAT)
    end

    def hinter
      @hinter ||= AlgHintParser.maybe_parse_hints(@options.alg_set, @options.verbose)
    end

    def generate
      Zip::File.open(@options.output, Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream('deck.tsv') do |deck_output_stream|
          CSV(deck_output_stream, :col_sep => "\t") do |csv|
            generate_internal(zipfile, csv)
          end
        end
      end
    end
    
    def generate_internal(zipfile, csv)
      state = @options.color_scheme.solved_cube_state(@options.cube_size)
      hinter.entries.each do |name, alg|
        puts name
        filename = "#{name}.#{FORMAT}"
        csv << [name, alg, filename]
        alg.inverse.apply_temporarily_to(state) do
          zipfile.get_output_stream(filename) do |f|
            f.write(@visualizer.fetch(state))
          end
        end
      end
    end
    
  end

end
