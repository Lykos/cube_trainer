# frozen_string_literal: true

# A fake learner that learns stuff and forgets it after a while.
class FakeLearner
  FORGET_RATE = 0.01

  # Learn stats of the fake learner.
  class LearnStats
    def initialize(seed)
      @rng = Random.new(seed)
      @optimal_time = @rng.rand + 1
      @initial_time = 50 + @rng.rand(50)
      @current_time = @initial_time
      @learning_rate = (@rng.rand * 0.05) + 0.05
      @practiced = 0
    end

    attr_reader :current_time

    def forget_rate
      FORGET_RATE**@practiced
    end

    def forget(number)
      return unless number

      remembered_stuff = (1 - forget_rate)**number
      (@current_time * remembered_stuff) + (@initial_time * (1 - remembered_stuff))
    end

    def execution_time
      (@current_time * 0.9) + (rand * @current_time * 0.2)
    end

    # Each practice gets you by learn rate closer to the optimum.
    def execute
      time = execution_time
      @practiced += 1
      @current_time = (@current_time * (1 - @learning_rate)) + (@optimal_time * @learning_rate)
      time
    end
  end

  def initialize
    @input_stats = {}
    @input_stats.default_proc = proc { |h, k| h[k] = LearnStats.new(k.hash) }
    @indices = {}
    @current_index = 0
  end

  def items_learned
    @input_stats.length
  end

  def average_time
    current_times = @input_stats.values.map(&:current_time)
    current_times.sum / current_times.length
  end

  def items_in_between(input)
    @current_index - @indices[input] if @indices[input]
  end

  def execute(input)
    stats = @input_stats[input]
    if (n = items_in_between(input))
      stats.forget(n)
    end
    @indices[input] = @current_index
    @current_index += 1
    { casee: input.casee, time_s: stats.execute, failed_attempts: 0, word: nil }
  end
end
