require 'input_sampler'
require 'alg_name'
require 'alg_hint_parser'
require 'input_item'

module CubeTrainer

  class AlgSet

    include StringHelper
    
    def initialize(results_model, options)
      @color_scheme = options.color_scheme
      @cube_size = options.cube_size
      @hinter = maybe_parse_hints(name, options.verbose)
      @input_sampler = InputSampler.new(generate_input_items(hinter.entries), results_model, goal_badness, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler, :hinter

    def goal_badness
      raise NotImplementedError
    end

    def name
      snake_case_class_name(self.class)
    end

    def generate_input_items(alg_entries)
      state = @color_scheme.solved_cube_state(@cube_size)
      alg_entries.map do |name, alg|
        alg.apply_temporarily_to(state) do
          InputItem.new(AlgName.new(a), state.dup)
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

end
