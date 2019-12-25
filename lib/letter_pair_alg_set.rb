require 'letter_pair_helper'
require 'input_sampler'
require 'buffer_helper'

module CubeTrainer

  class LetterPairAlgSet

    include LetterPairHelper
  
    def initialize(results_model, options)
      @letter_scheme = options.letter_scheme
      @options = options
      @input_sampler = InputSampler.new(letter_pairs, results_model, goal_badness, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler, :letter_scheme, :options

    def buffer
      @buffer ||= BufferHelper.determine_buffer(self.class::PART_TYPE, options)
    end

    def goal_badness
      raise NotImplementedError
    end

    def letter_pairs
      @letter_pairs ||= begin
                          generated_letter_pairs = generate_letter_pairs
                          restricted_letter_pairs = if options.restrict_letters and not options.restrict_letters.empty?
                                                      generated_letter_pairs.select { |p| p.has_any_letter?(options.restrict_letters) }
                                                    else
                                                      generated_letter_pairs
                                                    end
                          restricted_letter_pairs.reject { |p| p.has_any_letter?(options.exclude_letters) }
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
