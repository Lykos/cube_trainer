require 'letter_pair_helper'
require 'input_sampler'
require 'dict'

module CubeTrainer

  class LettersToWord
  
    def initialize(results_model)
      @results_model = results_model
      @input_sampler = InputSampler.new(VALID_PAIRS, results_model)
    end

    attr_reader :input_sampler

    VALID_PAIRS = LetterPairHelper.letter_pairs(ALPHABET.permutation(2)) - LetterPairHelper.letter_pairs(ALPHABET.collect { |c| [c, c] }) + LetterPairHelper.letter_pairs(ALPHABET.permutation(1))
  
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
  
    def hint(letter_pair)
      words = @results_model.words_for_input(letter_pair)
      if words.empty?
        if letter_pair.letters.first.downcase == 'x'
          dict.words_for_regexp(letter_pair.letters[1], Regexp.new(letter_pair.letters[1]))
        else
          dict.words_for_regexp(letter_pair.letters.first, letter_pair.regexp)
        end
      else
        words
      end
    end
  
    def good_word?(letter_pair, word)
      return false unless letter_pair.matches_word?(word)
      other_combinations = @results_model.inputs_for_word(word) - [letter_pair]
      return false unless other_combinations.empty?
      past_words = @results_model.words_for_input(letter_pair)
      raise 'Invalid number of past words.' if past_words.length > 1
      if past_words.length == 1
        past_words[0] == word
      else
        true
      end
    end
  
  end

end
