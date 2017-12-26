class Trainer
  def initialize(learner, results_model, generator)
    @learner = learner
    @results_model = results_model
    @generator = generator
  end

  def one_iteration
    input = @generator.random_item
    timestamp = Time.now
    time_s = @learner.execute(input)
    @results_model.record_result(timestamp, time_s, input)
  end

  def run
    loop do
      one_iteration
    end
  end
end
