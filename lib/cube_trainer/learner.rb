require 'cube_trainer/result'

module CubeTrainer

  class Learner
    FORGET_RATE = 0.01
    
    class LearnStats
      def initialize(seed)
        @rng = Random.new(seed)
        @optimal_time = @rng.rand + 1
        @initial_time = 50 + @rng.rand(50)
        @current_time = @initial_time
        @learning_rate = @rng.rand * 0.05 + 0.05
        @practiced = 0
      end
  
      attr_reader :current_time
  
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
        @current_time = @current_time * (1 - @learning_rate) + @optimal_time * @learning_rate
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
      current_times = @input_stats.values.collect { |v| v.current_time }
      current_times.reduce(:+) / current_times.length
    end
  
    def items_in_between(input)
      @current_index - @indices[input] if @indices[input]
    end
  
    def execute(input)
      stats = @input_stats[input]
      if n = items_in_between(input)
        stats.forget(n)
      end
      @indices[input] = @current_index
      @current_index += 1
      PartialResult.new(stats.execute, 0, nil)
    end
  end

end
