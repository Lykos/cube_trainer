class Trainer
  def initialize(learner, results_model, generator)
    @learner = learner
    @results_model = results_model
    @generator = generator
  end

  def run
    loop do
      input = @generator.random_letter_pair
      timestamp = Time.now
      time_s = @learner.execute(input)
      @results_model.record_result(timestamp, time_s, input)
    end
  end
end
