# frozen_string_literal: true

require 'cube_trainer/letter_pair_helper'
require 'cube_trainer/input_sampler'
require 'cube_trainer/buffer_helper'
require 'cube_trainer/input_item'

module CubeTrainer
  # Class that generates input items for items that can be represented by letter pairs.
  class LetterPairAlgSet
    include LetterPairHelper

    def initialize(results_model, options)
      @letter_scheme = options.letter_scheme
      @color_scheme = options.color_scheme
      @options = options
      @input_sampler = InputSampler.new(input_items,
                                        results_model,
                                        goal_badness,
                                        options.verbose,
                                        options.new_item_boundary)
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

    def restricted_input_items
      if options.restrict_letters && !options.restrict_letters.empty?
        generate_input_items.select do |p|
          p.representation.contains_any_letter?(options.restrict_letters)
        end
      else
        generate_input_items
      end
    end

    def input_items
      @input_items ||= restricted_input_items.reject do |p|
        p.representation.contains_any_letter?(options.exclude_letters)
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
