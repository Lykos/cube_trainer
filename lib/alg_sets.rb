require 'input_sampler'
require 'alg_name'

module CubeTrainer

  class PllsByName
    def initialize(results_model, options)
      @input_sampler = InputSampler.new(VALID_PAIRS, results_model, 1.0, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler

    class NoHinter
      def hint(*args)
        'No hints available'
      end
    end
    
    def hinter
      # TODO implement this
      NoHinter.new
    end

    VALID_PAIRS = ['Ja', 'Jb', 'Ua', 'Ub', 'Na', 'Nb', 'Ra', 'Rb', 'Z', 'H', 'T', 'Y', 'V', 'Ga', 'Gb', 'Gc', 'Gd', 'F', 'E', 'Aa', 'Ab'].map { |a| AlgName.new(a) }

  end
  
end
