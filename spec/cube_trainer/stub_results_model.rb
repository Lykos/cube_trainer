# frozen_string_literal: true

class StubResultPersistence
  def load_results(_mode)
    []
  end
end

class StubResultsModel
  def add_result_listener(*args); end

  def record_result(*args); end

  def delete_after_time(*args); end

  def last_word_for_input(*args); end

  def inputs_for_word(*args); end

  def results
    []
  end

  def mode
    :mode
  end

  def result_persistence
    @result_persistence ||= StubResultPersistence.new
  end
end
