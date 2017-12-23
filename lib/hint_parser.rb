require 'csv'
require 'commutator'

class HintParser
  def self.csv_file(part_class)
    # TODO Filename construction sucks
    "data/#{part_class.to_s}.csv"
  end
  
  def self.parse_hints(part_class)
    hints = {}
    hint_table = CSV.read(csv_file(part_class))
    # TODO make this more general to figure out other types of hint tables
    parts = hint_table[0][1..-1].collect { |p| part_class.parse(p) }
    hint_table[1..-1].each_with_index do |row, row_index|
      break if row.first.nil? || row.first.empty?
      part1 = part_class.parse(row.first)
      row[1..-1].each_with_index do |e, i|
        next if e.nil? || e.empty?
        part0 = parts[i]
        letter_pair = LetterPair.new([part0.letter, part1.letter])
        begin
          hints[letter_pair] = parse_commutator(e)
        rescue CommutatorParseError => e
          raise "Couldn't parse commutator for #{letter_pair} (i.e. #{("A".."Z").to_a[i + 1]}#{row_index + 2}) couldn't be parsed: #{e}"
        end
      end
    end
    hints
  end

  def self.maybe_create(part_class)
    new(if File.exists?(csv_file(part_class))
      parse_hints(part_class)
    else
      {}
    end)
  end

  def initialize(hints)
    @hints = hints
  end

  def hint(letter_pair)
    @hints[letter_pair] ||= begin
                              inverse = @hints[letter_pair.invert]
                              if inverse then inverse.invert else nil end
                            end
  end
end
