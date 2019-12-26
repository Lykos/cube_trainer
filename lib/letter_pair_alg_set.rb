require 'letter_pair_helper'
require 'input_sampler'
require 'buffer_helper'
require 'input_item'

module CubeTrainer

  class LetterPairAlgSet

    include LetterPairHelper
  
    def initialize(results_model, options)
      @letter_scheme = options.letter_scheme
      @options = options
      @input_sampler = InputSampler.new(input_items, results_model, goal_badness, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler, :letter_scheme, :options

    def buffer
      @buffer ||= BufferHelper.determine_buffer(self.class::PART_TYPE, options)
    end

    def goal_badness
      raise NotImplementedError
    end

    def generate_input_items
      generate_letter_pairs.map { |e| InputItem.new(e) }
    end

    def input_items
      @input_items ||= begin
                         generated_input_items = generate_input_items
                         restricted_input_items = if options.restrict_letters and not options.restrict_letters.empty?
                                                     generated_input_items.select { |p| p.representation.has_any_letter?(options.restrict_letters) }
                                                   else
                                                     generated_input_items
                                                   end
                         restricted_input_items.reject { |p| p.representation.has_any_letter?(options.exclude_letters) }
                       end
    end
    
    def generate_letter_pairs
      raise NotImplementedError
    end

    def hinter
      raise NotImplementedError
    end
  end

end
