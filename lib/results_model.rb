require 'results_persistence'


class ResultsModel

  def initialize(mode)
    @mode = mode
    @result_persistence = ResultsPersistence.new
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
    @result_persistence.store_results(@results)
  end

end
