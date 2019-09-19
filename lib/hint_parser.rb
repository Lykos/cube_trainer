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
    def csv_file
      "data/#{name}.csv"
    end

    FACE_REGEXP = Regexp.new("[#{(FACE_NAMES + FACE_NAMES.map { |f| f.downcase }).join("")}]{2,3}")

    def parse_part(s)
      # Try to parse it as a letter.
      if parse_letter_scheme.has_letter?(s)
        return parse_letter_scheme.for_letter(part_type, s)
      end
      # Try to parse it as a description like UBL.
      faces = s[FACE_REGEXP]
      raise "Couldn't figure out which part #{s} is. It doesn't look like a letter or a combination of faces." unless faces
      part = part_type.parse(faces)
      raise "Couldn't figure out which part #{s} is. Couldn't find the right part." unless part
      part
    end

    def letter_pair(part0, part1)
      LetterPair.new([part0, part1].map { |p| letter_scheme.letter(p) })
    end

    BLACKLIST = ['flip']

    # Recognizes special cell values that are blacklisted because they are not commutators
    def blacklisted?(value)
      BLACKLIST.include?(value.downcase)
    end
    
    def parse_hints(cube_size, check_comms)
      checker = if check_comms
                  CommutatorChecker.new(part_type, buffer, name, cube_size)
                else
                  CommutatorCheckerStub.new
                end
      hints = {}
      hint_table = CSV.read(csv_file)
      # TODO make this more general to figure out other types of hint tables
      parts = hint_table[0][1..-1].collect do |p|
        if p.nil? or p.empty?
          nil
        else
          parse_part(p)
        end
      end
      hint_table[1..-1].each_with_index do |row, row_index|
        break if row.first.nil? or row.first.empty?
        part1 = parse_part(row.first)
        row[1..-1].each_with_index do |e, i|
          next if e.nil? || e.empty? || blacklisted?(e)
          part0 = parts[i]
          next if part0.nil?
          letter_pair = letter_pair(part0, part1)
          row_description = "#{("A".."Z").to_a[i + 1]}#{row_index + 2}"
          begin
            commutator = parse_commutator(e)
            check_result = checker.check_alg(row_description, letter_pair, [part0, part1], commutator)
            hints[letter_pair] = commutator if check_result == :correct
          rescue CommutatorParseError => e
            puts "Couldn't parse commutator for #{letter_pair} (i.e. #{row_description}) couldn't be parsed: #{e}" if verbose
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
      @hints = hints.map { |k, v| [k, [v]] }.to_h
    end
  
    def hints(letter_pair)
      @hints[letter_pair] ||= begin
                                inverse = @hints[letter_pair.inverse]
                                if inverse then [inverse.inverse] else [] end
                              end
    end
  end

  class NoHinter
    def hints(*args)
      []
    end
  end

end
