require 'letter_pair_helper'
require 'input_sampler'

module CubeTrainer

  class LetterPairAlgSet

    include LetterPairHelper
  
    def initialize(results_model, options, buffer)
      raise ArgumentError, "Buffer has an invalid type." if buffer and not buffer.class == part_type
      @buffer = buffer
      @letter_scheme = options.letter_scheme
      @options = options
      @input_sampler = InputSampler.new(letter_pairs, results_model, goal_badness, options.verbose, options.new_item_boundary)
    end

    attr_reader :input_sampler, :letter_scheme, :buffer, :options

    def part_type
      raise NotImplementedError
    end

    def goal_badness
      raise NotImplementedError
    end

    def letter_pairs
      @letter_pairs ||= begin
                          generated_letter_pairs = generate_letter_pairs
                          restricted_letter_pairs = if options.restrict_letters? and not options.restrict_letters.empty?
                                                      generated_letter_pairs.select { |p| p.letters.any? { |l| options.restrict_letters.include?(l) } }
                                                    else
                                                      generated_letter_pairs
                                                    end
                          restricted_letter_pairs.reject { |p| p.letters.any? { |l| options.exclude_letters.include?(l) } }
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
