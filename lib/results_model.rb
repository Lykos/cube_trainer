require 'results_persistence'
require 'result'

module CubeTrainer

  class ResultsModel
  
    def initialize(mode, results_persistence=ResultsPersistence.create_for_production)
      @mode = mode
      @result_persistence = results_persistence
      @results = @result_persistence.load_results
      @result_listeners = [@result_persistence]
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
  
    def add_result_listener(listener)
      @result_listeners.push(listener)
    end
  
    def record_result(timestamp, partial_result, input)
      raise ArgumentError unless partial_result.is_a?(PartialResult)
      result = Result.from_partial(@mode, timestamp, partial_result, input)
      results.unshift(result)
      @result_listeners.each { |l| l.record_result(result) }
    end
  
    def delete_after_time(timestamp)
      results.delete_if { |r| r.timestamp > timestamp }
      @result_listeners.each { |l| l.delete_after_time(@mode, timestamp) }
    end
    
    def last_word_for_input(input)
      result = results.select { |r| r.input == input }.max_by { |r| r.timestamp }
      if result.nil? then nil else result.word end
    end
  
    def inputs_for_word(word)
      results.select { |r| r.word == word }.collect { |r| r.input }.uniq
    end
  
  end

end
