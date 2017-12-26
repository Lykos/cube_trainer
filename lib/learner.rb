class Learner
  LEARN_RATE = 0.1
  FORGET_RATE = 0.1
  
  class LearnStats
    def initialize(optimal_time, initial_time)
      @optimal_time = optimal_time
      @initial_time = initial_time
      @current_time = initial_time
      @practiced = 0
    end

    def forget_rate
      FORGET_RATE ** @practiced
    end

    def forget(n)
      return unless n
      remembered_stuff = (1 - forget_rate) ** n 
      @current_time * remembered_stuff + @initial_time * (1 - remembered_stuff)
    end

    def execution_time
      @current_time * 0.9 + rand * @current_time * 0.2
    end

    # Each practice gets you by learn rate closer to the optimum.
    def execute
      time = execution_time
      @practiced += 1
      @current_time = @current_time * (1 - LEARN_RATE) + @optimal_time * LEARN_RATE
      time
    end
  end
  
  def initialize
    @input_stats = {}
    @input_stats.default_proc = { || LearnStats.new(1 + rand, 2 + rand * 100) }
    @indices = {}
    @current_index = 0
  end

  def items_in_between(input)
    @current_index - @indices[input]
  end

  def execute(input)
    stats = @input_stats(input)
    if n = items_in_between(input)
      stats.forget(n)
    end
    @indices[input] = @current_index
    @current_index += 1
    stats.execute
  end
end
