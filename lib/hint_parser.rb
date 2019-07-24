require 'csv'
require 'commutator'
require 'move'
require 'buffer_helper'
require 'commutator_checker'
require 'cube'

module CubeTrainer

  class CommutatorCheckerStub
    def initialize
      @total_algs = 0
    end
    
    attr_reader :total_algs
    
    def check_alg(*args)
      @total_algs += 1
      :correct
    end

    def broken_algs
      0
    end
  end

  class HintParser
    def csv_file
      "data/#{name}.csv"
    end

    FACE_REGEXP = Regexp.new("[#{(FACE_NAMES + FACE_NAMES.map { |f| f.downcase }).join("")}]{2,3}")

    def letter_pair(part0, part1)
      LetterPair.new([part0, part1].map { |p| letter_scheme.letter(p) })
    end

    BLACKLIST = ['flip']

    # Recognizes special cell values that are blacklisted because they are not commutators
    def blacklisted?(value)
      BLACKLIST.include?(value.downcase)
    end

    class AlgEntry
      def initialize(algorithm)
        @algorithm = algorithm
      end

      attr_reader :algorithm
    end

    def parse_hints(cube_size, check_comms)
      hint_table = CSV.read(csv_file)

      # First parse whatever we can
      alg_table = hint_table.map { |row| row.map { nil } }
      hint_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          next if cell.nil? || cell.empty? || blacklisted?(cell)
          #cell_description = "#{("A".."Z").to_a[col_index]}#{row_index + 1}"
          begin
            alg = parse_commutator(e)
            alg_table[row_index][col_index] = alg
            # check_result = checker.check_alg(row_description, letter_pair, [part0, part1], commutator)
            # hints[letter_pair] = commutator if check_result == :correct
          rescue CommutatorParseError => e
            alg_table[row_index][col_index] = ErrorEntry.new("Couldn't parse commutator for #{letter_pair} (i.e. #{row_description}) couldn't be parsed: #{e}")
          end
        end
      end

      # Now figure out whether rows are the first piece or the second piece.
      checker = if check_comms
                  CommutatorChecker.new(part_type, buffer, name, cube_size)
                else
                  CommutatorCheckerStub.new
                end
      hints = {}
      if checker.broken_algs > 0
        puts "#{checker.broken_algs} broken algs of #{checker.total_algs}. #{checker.unfixable_algs} were unfixable."
      elsif verbose
        puts "Parsed #{checker.total_algs} algs."
      end
      hints
    end

    def initialize(part_type, buffer, letter_scheme, verbose)
      @part_type = part_type
      @buffer = buffer
      @name = buffer.to_s.downcase + '_' + part_type.name.split('::').last.downcase
      @parse_letter_scheme = @letter_scheme = letter_scheme
      @verbose = verbose
    end

    attr_reader :name, :part_type, :buffer, :letter_scheme, :parse_letter_scheme, :verbose

  end
   
  class Hinter
    def self.maybe_create(part_type, options)
      buffer = BufferHelper.determine_buffer(part_type, options)
      hint_parser = HintParser.new(part_type, buffer, options.letter_scheme, options.verbose)
      hints = if File.exists?(hint_parser.csv_file)
                hint_parser.parse_hints(options.cube_size, options.test_comms)
              else
                puts "Failed to find hint CSV file #{hint_parser.csv_file}." if options.verbose
                {}
              end
      new(hints)
    end
 
    def initialize(hints)
      @hints = hints
    end
  
    def hint(letter_pair)
      @hints[letter_pair] ||= begin
                                inverse = @hints[letter_pair.inverse]
                                if inverse then inverse.inverse else nil end
                              end
    end
  end

  class NoHinter
    def hint(*args)
      'No hints available'
    end
  end

end
