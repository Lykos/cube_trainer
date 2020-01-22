require 'cube_trainer/letter_pair_helper'
require 'cube_trainer/input_sampler'
require 'cube_trainer/letter_pair_alg_set'
require 'cube_trainer/pao_letter_pair'
require 'cube_trainer/dict'

module CubeTrainer

  class LettersToWord < LetterPairAlgSet

    def initialize(results_model, options)
      super
      @results_model = results_model
    end

    # TODO The setup with badness makes much less sense here and should be revised.
    def goal_badness
      5.0
    end
  
    def generate_letter_pairs
      alphabet = letter_scheme.alphabet
      pairs = LetterPairHelper.letter_pairs(alphabet.permutation(2))
      duplicates = LetterPairHelper.letter_pairs(alphabet.collect { |c| [c, c] })
      singles = LetterPairHelper.letter_pairs(alphabet.permutation(1))
      valid_pairs = pairs - duplicates + singles
      PaoLetterPair::PAO_TYPES.product(valid_pairs).collect { |c| PaoLetterPair.new(*c) }
    end

    attr_reader :input_sampler

    # TODO move this to the dict
    def hinter
      self
    end
  
    def dict
      @dict ||= Dict.new
    end
  
    def hints(pao_letter_pair)
      letter_pair = pao_letter_pair.letter_pair
      word = @results_model.last_word_for_input(pao_letter_pair)
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
