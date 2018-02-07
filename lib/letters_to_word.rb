require 'letter_pair_helper'
require 'input_sampler'
require 'pao_letter_pair'
require 'dict'

module CubeTrainer

  class LettersToWord

    # TODO The setup with badness makes much less sense here and should be revised.
    GOAL_BADNESS = 5.0
  
    def initialize(results_model, options)
      @results_model = results_model
      @input_sampler = InputSampler.new(VALID_PAIRS, results_model, GOAL_BADNESS, options.verbose, options.new_item_boundary)
    end

    VALID_PAIRS = begin
                    pairs = LetterPairHelper.letter_pairs(ALPHABET.permutation(2))
                    duplicates = LetterPairHelper.letter_pairs(ALPHABET.collect { |c| [c, c] })
                    singles = LetterPairHelper.letter_pairs(ALPHABET.permutation(1))
                    valid_pairs = pairs - duplicates + singles
                    PaoLetterPair::PAO_TYPES.product(valid_pairs).collect { |c| PaoLetterPair.new(*c) }
                  end

    attr_reader :input_sampler

    # TODO remove once we migrated it to the other sampler class
    def random_letter_pair
      @input_sampler.random_input
    end

    # TODO move this to the dict
    def hinter
      self
    end
  
    def dict
      @dict ||= Dict.new
    end
  
    def hint(input)
      letter_pair = input.letter_pair
      word = @results_model.last_word_for_input(input)
      if word.nil?
        if letter_pair.letters.first.downcase == 'x'
          dict.words_for_regexp(letter_pair.letters[1], Regexp.new(letter_pair.letters[1]))
        else
          dict.words_for_regexp(letter_pair.letters.first, letter_pair.regexp)
        end
      else
        [word]
      end
    end
  
    def good_word?(input, word)
      return false unless input.matches_word?(word)
      other_combinations = @results_model.inputs_for_word(word) - [input]
      return false unless other_combinations.empty?
      last_word = @results_model.last_word_for_input(input)
      last_word.nil? || last_word == word
    end
  
  end

end
