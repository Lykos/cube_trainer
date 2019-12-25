require 'commutator_reverse_engineer'
require 'commonality_finder'
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
      raise ArgumentError unless cube_size.is_a?(Integer)
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
      def initialize(letter_pair, algorithm)
        @maybe_letter_pair = letter_pair
        @algorithm = algorithm
      end

      attr_reader :letter_pair, :algorithm
      attr_accessor :maybe_letter_pair
    end

    class EmptyEntry
      def initialize
        @maybe_letter_pair = nil
      end

      attr_accessor :maybe_letter_pair
    end

    class ErrorEntry
      def initialize(error_message)
        @error_message = error_message
        @maybe_letter_pair = nil
      end

      attr_reader :error_message
      attr_accessor :maybe_letter_pair
    end

    def add_nils_to_table(table)
      max_row_length = table.map { |row| row.length }.max
      table.map { |row| row + [nil] * (max_row_length - row.length) }
    end

    def parse_hints
      parse_hint_table(add_nils_to_table(CSV.read(csv_file)))
    end
    
    def parse_hint_table(hint_table)
      # First parse whatever we can
      alg_table = hint_table.map { |row| row.map { EmptyEntry.new } }
      reverse_engineer = CommutatorReverseEngineer.new(part_type, buffer, letter_scheme, cube_size)
      hint_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          next if cell.nil? || cell.empty? || blacklisted?(cell)
          row_description = "#{("A".."Z").to_a[col_index]}#{row_index + 1}"
          begin
            alg = parse_commutator(cell)
            # Ignore very short algorithms. They are never valid and they can be things like piece types.
            next if alg.algorithm.length <= 3
            maybe_letter_pair = reverse_engineer.find_letter_pair(alg.algorithm)
            alg_table[row_index][col_index] = AlgEntry.new(maybe_letter_pair, alg)
          rescue CommutatorParseError => e
            alg_table[row_index][col_index] = ErrorEntry.new("Couldn't parse commutator: #{e}")
          end
        end
      end

      # Now figure out whether rows are the first piece or the second piece.
      interpretation = CommonalityFinder.interpret_table(alg_table)

      # Now check everything and construct the hint table.
      checker = if test_comms
                  CommutatorChecker.new(part_type, buffer, name, cube_size)
                else
                  CommutatorCheckerStub.new
                end
      errors = []
      hints = {}
      alg_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          letter_pair = interpretation.letter_pair(row_index, col_index)
          row_description = "#{("A".."Z").to_a[col_index]}#{row_index}"
          if letter_pair.nil?
            if cell.is_a?(AlgEntry)
              puts "Algorithm #{cell.algorithm} at #{row_description} is outside of the valid part of the table." if test_comms
            else
              # Ignore this. Any invalid stuff can be outside the interesting part of the table.
            end
          elsif cell.is_a?(ErrorEntry)
            puts "Algorithm for #{letter_pair} at #{row_description} has a problem: cell.error_message." if test_comms
          elsif cell.is_a?(AlgEntry)
            commutator = cell.algorithm
            parts = letter_pair.letters.map { |l| letter_scheme.for_letter(part_type, l) }
            check_result = checker.check_alg(row_description, letter_pair, parts, commutator)
            hints[letter_pair] = commutator if check_result == :correct
          end
        end
      end
      
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
