# frozen_string_literal: true

require 'cube_trainer/commutator_reverse_engineer'
require 'cube_trainer/commutator_hinter'
require 'cube_trainer/commonality_finder'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/hint_parser'
require 'cube_trainer/buffer_helper'
require 'cube_trainer/commutator_checker'
require 'cube_trainer/utils/string_helper'

module CubeTrainer
  # Stub commutator checker that just says everything is always okay.
  class CommutatorCheckerStub
    def initialize
      @total_algs = 0
    end

    attr_reader :total_algs

    def check_alg(*_args)
      @total_algs += 1
      CommutatorChecker::CheckAlgResult::CORRECT
    end

    def broken_algs
      0
    end

    def error_algs
      0
    end
  end

  # Class that parses a commutator file.
  class CommutatorHintParser < HintParser
    TEST_COMMS_MODES = %i[ignore warn fail].freeze

    include Utils::StringHelper
    include Core

    def initialize(part_type:, buffer:, letter_scheme:, color_scheme:, verbose:, cube_size:, test_comms_mode:)
      unless TEST_COMMS_MODES.include?(test_comms_mode)
        raise ArgumentError, "Invalid test comms mode #{test_comms_mode}. Allowed are: #{TEST_COMMS_MODES.inspect}"
      end
      if test_comms_mode == :warn && !verbose
        raise ArgumentError, 'Having test_comms_mode == :warn, but !verbose is pointless.'
      end
      raise ArgumentError unless cube_size.is_a?(Integer)

      @part_type = part_type
      @buffer = buffer
      @name = buffer.to_s.downcase + '_' + snake_case_class_name(part_type)
      @letter_scheme = letter_scheme
      @color_scheme = color_scheme
      @verbose = verbose
      @cube_size = cube_size
      @test_comms_mode = test_comms_mode
    end

    attr_reader :name, :part_type, :buffer, :verbose, :cube_size, :test_comms_mode

    FACE_REGEXP = Regexp.new("[#{(Core::CubeConstants::FACE_NAMES + Core::CubeConstants::FACE_NAMES.map(&:downcase)).join('')}]{2,3}")

    def letter_pair(part0, part1)
      LetterPair.new([part0, part1].map { |p| @letter_scheme.letter(p) })
    end

    def warn_comms?
      @test_comms_mode != :ignore && @verbose
    end

    def fail_comms?
      @test_comms_mode == :fail
    end

    BLACKLIST = ['flip'].freeze

    # Recognizes special cell values that are blacklisted because they are not commutators
    def blacklisted?(value)
      BLACKLIST.include?(value.downcase)
    end

    # Represents an entry with an alg in a commutator table.
    class AlgEntry
      def initialize(letter_pair, algorithm)
        @maybe_letter_pair = letter_pair
        @algorithm = algorithm
      end

      attr_reader :letter_pair, :algorithm
      attr_accessor :maybe_letter_pair
    end

    # Represents an empty entry in a commutator table.
    class EmptyEntry
      def initialize
        @maybe_letter_pair = nil
      end

      attr_accessor :maybe_letter_pair
    end

    # Represents an erroneous entry in a commutator table.
    class ErrorEntry
      def initialize(error_message)
        @error_message = error_message
        @maybe_letter_pair = nil
      end

      attr_reader :error_message
      attr_accessor :maybe_letter_pair
    end

    def add_nils_to_table(table)
      max_row_length = table.map(&:length).max
      table.map { |row| row + [nil] * (max_row_length - row.length) }
    end

    def parse_hints_internal(raw_hints)
      parse_hint_table(add_nils_to_table(raw_hints))
    end

    def checker
      @checker ||= if @test_comms_mode == :ignore
                     CommutatorCheckerStub.new
                   else
                     CommutatorChecker.new(
                       part_type: @part_type,
                       buffer: @buffer,
                       piece_name: name,
                       color_scheme: @color_scheme,
                       letter_scheme: @letter_scheme,
                       cube_size: @cube_size,
                       verbose: @verbose,
                       find_fixes: @verbose
                     )
                   end
    end

    def parse_hint_table(hint_table)
      # First parse whatever we can
      alg_table = hint_table.map { |row| row.map { EmptyEntry.new } }
      reverse_engineer = CommutatorReverseEngineer.new(@part_type, @buffer, @letter_scheme, @cube_size)
      hint_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          next if cell.nil? || cell.empty? || blacklisted?(cell)

          begin
            alg = parse_commutator(cell)
            # Ignore very short algorithms. They are never valid and they can be things like piece types.
            next if alg.algorithm.length <= 3

            maybe_letter_pair = reverse_engineer.find_letter_pair(alg.algorithm)
            alg_table[row_index][col_index] = AlgEntry.new(maybe_letter_pair, alg)
          rescue Core::CommutatorParseError => e
            alg_table[row_index][col_index] = ErrorEntry.new("Couldn't parse commutator: #{e}")
          end
        end
      end

      # Now figure out whether rows are the first piece or the second piece.
      interpretation = CommonalityFinder.interpret_table(alg_table)

      # Now check everything and construct the hint table.
      hints = {}
      alg_table.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          letter_pair = interpretation.letter_pair(row_index, col_index)
          row_description = "#{('A'..'Z').to_a[col_index]}#{row_index}"
          if letter_pair.nil?
            if cell.is_a?(AlgEntry)
              if warn_comms?
                puts "Algorithm #{cell.algorithm} at #{row_description} is outside of the valid part of the table."
              end
            else
              # Ignore this. Any invalid stuff can be outside the interesting part of the table.
            end
          elsif cell.is_a?(ErrorEntry)
            checker.count_error_alg
            if warn_comms?
              puts "Algorithm for #{letter_pair} at #{row_description} has a problem: #{cell.error_message}."
            end
          elsif cell.is_a?(AlgEntry)
            commutator = cell.algorithm
            check_result = checker.check_alg(row_description, letter_pair, commutator).result
            hints[letter_pair] = commutator if check_result == :correct
          end
        end
      end

      if checker.broken_algs.positive? || checker.error_algs.positive?
        msg = "#{checker.error_algs} error algs and #{checker.broken_algs} broken algs of #{checker.total_algs}."
        msg += " #{checker.unfixable_algs} were unfixable." if checker.unfixable_algs
        raise msg if fail_comms?

        puts msg if warn_comms?
      elsif @verbose
        puts "Parsed #{checker.total_algs} algs."
      end
      hints
    end

    def hinter_class
      CommutatorHinter
    end

    def self.maybe_parse_hints(part_type, options)
      buffer = BufferHelper.determine_buffer(part_type, options)
      hint_parser = CommutatorHintParser.new(
        part_type: part_type,
        buffer: buffer,
        letter_scheme: options.letter_scheme,
        color_scheme: options.color_scheme,
        verbose: options.verbose,
        cube_size: options.cube_size,
        test_comms_mode: options.test_comms_mode
      )
      hint_parser.maybe_parse_hints
    end
  end
end
