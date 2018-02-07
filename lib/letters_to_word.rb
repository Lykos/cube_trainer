require 'letter_pair_helper'
require 'input_sampler'
require 'pao_letter_pair'
require 'dict'

module CubeTrainer

  class LettersToWord
  
    def initialize(results_model)
      @results_model = results_model
      @input_sampler = InputSampler.new(VALID_PAIRS, results_model)
    end

    VALID_PAIRS = begin
                    pairs = LetterPairHelper.letter_pairs(ALPHABET.permutation(2))
                    duplicates = LetterPairHelper.letter_pairs(ALPHABET.collect { |c| [c, c] })
                    singles = LetterPairHelper.letter_pairs(ALPHABET.permutation(1))
                    valid_pairs = pairs - duplicates + singles
                    PaoLetterPair::PAO_TYPES.product(valid_pairs)
                  end

    attr_reader :input_sampler
  
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
  
    def hint(pao_letter_pair)
      letter_pair = pao_letter_pair.letter_pair
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
  
    def good_word?(pao_letter_pair, word)
      letter_pair = pao_letter_pair.letter_pair
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
