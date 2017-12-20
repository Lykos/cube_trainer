require 'yaml_persistence'

class ResultsModel

  def initialize(mode)
    @mode = mode
    @result_persistence = YamlPersistence.new
    @results = @result_persistence.load_results
  end

  attr_reader :mode

  def results
    @mode_results ||= begin
                        unless @results.has_key?(@mode)
                          @results[@mode] = []
                        end
                        @results[@mode]
                      end
  end

  def record_result(result)
    results.unshift(result)
  end
  
  def store
    @result_persistence.store_results(@results)
  end

  def words_for_input(input)
    results.select { |r| r.input == input }.collect { |r| r.word }.uniq
  end

  def inputs_for_word(word)
    results.select { |r| r.word == word }.collect { |r| r.input }.uniq
  end

  def replace_word(input, word)
    results.collect! { |r| if r.input == input then r.with_word(word) else r end }
    store
  end

end
