module CubeTrainer
  class LetterScheme
    def initialize
      alphabet.each { |letter| raise "Uncanonical letter #{letter} in alphabet." if letter != canonicalize_letter(letter) }
    end

    def letter(piece)
      alphabet[piece.piece_index]
    end

    def for_letter(part_type, desired_letter)
      canonicalized_letter = canonicalize_letter(desired_letter)
      part_type::ELEMENTS.find { |e| letter(e) == canonicalized_letter }
    end

    def has_letter?(letter)
      alphabet.include?(canonicalize_letter(letter))
    end

    def alphabet
      raise NotImplementedError
    end

    def canonicalize_letter(letter)
      raise NotImplementedError
    end
  end

  class DefaultLetterScheme < LetterScheme
    def alphabet
      @alphabet ||= "a".upto("x").to_a
    end

    def canonicalize_letter(letter)
      letter.downcase      
    end

    # Letters that we shoot to by default.
    def shoot_letters(part_type)
      ['a', 'b', 'd', 'l', 'h', 't', 'p']
    end
  end
end
