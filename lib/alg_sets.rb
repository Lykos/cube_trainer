require 'input_sampler'
require 'alg_name'
require 'alg_hint_parser'
require 'input_item'

module CubeTrainer

  class AlgSet

    include StringHelper
    
    def initialize(results_model, options)
      @results_model = results_model
      @options = options
    end

    def input_sampler
      @input_sampler ||= InputSampler.new(input_items, @results_model, goal_badness, @options.verbose, @options.new_item_boundary)
    end

    def goal_badness
      raise NotImplementedError
    end

    def name
      snake_case_class_name(self.class)
    end

    def hinter
      @hinter ||= AlgHintParser.maybe_parse_hints(name, @options.verbose)
    end

    def input_items
      @input_items ||= generate_input_items
    end

    def generate_input_items
      state = @options.color_scheme.solved_cube_state(@options.cube_size)
      hinter.entries.map do |name, alg|
        alg.inverse.apply_temporarily_to(state) do
          InputItem.new(name, state.dup)
        end
      end
    end

    def generate_alg_names
      raise NotImplementedError
    end

  end

  class Plls < AlgSet

    def goal_badness
      1.0
    end

  end

  class Colls < AlgSet

    def goal_badness
      1.0
    end

  end

end
