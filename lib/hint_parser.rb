require 'commutator_reverse_engineer'
require 'csv'
require 'parser'
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

    def initialize(part_type, buffer, letter_scheme, verbose, cube_size, test_comms)
      @part_type = part_type
      @buffer = buffer
      @name = buffer.to_s.downcase + '_' + part_type.name.split('::').last.downcase
      @parse_letter_scheme = @letter_scheme = letter_scheme
      @verbose = verbose
      @cube_size = cube_size
      @test_comms = test_comms
    end

    attr_reader :name, :part_type, :buffer, :letter_scheme, :parse_letter_scheme, :verbose, :cube_size, :test_comms

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
      def initialize(maybe_letter_pair, algorithm)
        @maybe_letter_pair = maybe_letter_pair
        @algorithm = algorithm
      end

      attr_reader :maybe_letter_pair, :algorithm
    end

    class ErrorEntry
      def initialize(error_message)
        @error_message = error_message
      end

      attr_reader :error_message
    end

    def parse_hints(cube_size, check_comms)
      parse_hint_table(CSV.read(csv_file))
    end
    
    def parse_hint_table(hint_table)
      # First parse whatever we can
      alg_table = hint_table.map { |row| row.map { nil } }
      reverse_engineer = CommutatorReverseEngineer.new(part_type, buffer, cube_size)
      hint_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          next if cell.nil? || cell.empty? || blacklisted?(cell)
          #cell_description = "#{("A".."Z").to_a[col_index]}#{row_index + 1}"
          begin
            alg = parse_commutator(e)
            maybe_letter_pair = reverse_engineer.find_letter_pair(alg)
            alg_table[row_index][col_index] = AlgEntry.new(maybe_letter_pair, alg)
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

  end
   
  class Hinter
    def self.maybe_create(part_type, options)
      buffer = BufferHelper.determine_buffer(part_type, options)
      hint_parser = HintParser.new(part_type, buffer, options.letter_scheme, options.verbose, options.cube_size, options.test_comms)
      hints = if File.exists?(hint_parser.csv_file)
                hint_parser.parse_hints
              else
                puts "Failed to find hint CSV file #{hint_parser.csv_file}." if options.verbose
                {}
              end
      new(hints)
    end
 
    def initialize(hints)
      @hints = hints.map { |k, v| [k, [v]] }.to_h
    end
  
    def hints(letter_pair)
      @hints[letter_pair] ||= begin
                                inverse = @hints[letter_pair.inverse]
                                inverse.map { |e| e.inverse }
                              end
    end
  end

  class NoHinter
    def hints(*args)
      []
    end
  end

end
