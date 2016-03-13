require 'set'

class Dict

  DICT_PATHS = ['/usr/share/dict/words', '/usr/share/dict/swiss']

  def words
    @words ||= read_words
  end

  def read_words
    lines = DICT_PATHS.collect_concat { |p| File.readlines(p) }
    words = Set[]
    lines.each do |l|
      prefix_exists = 3.upto(l.length).any? { |i| words.include? l[0...i] }
      words.add(l.chomp) unless prefix_exists
    end
    words.to_a.sort.group_by { |w| w[0].downcase }
  end

  private :read_words

  def words_for_regexp(start_letter, regexp)
    words[start_letter].select { |w| w =~ regexp }
  end

end
