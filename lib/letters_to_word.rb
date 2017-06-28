require 'letter_pair_helper'
require 'sampling_helper'
require 'dict'

class LettersToWord

  include SamplingHelper
  include LetterPairHelper
  
  def initialize(results_model)
    @results_model = results_model
  end

  VALID_PAIRS = LETTER_PAIRS - REDUNDANT_TWISTS

  def results
    @results_model.results
  end

  def random_letter_pair
    random_input(VALID_PAIRS, results)
  end

  def dict
    @dict = Dict.new
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
