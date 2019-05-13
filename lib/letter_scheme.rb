module CubeTrainer
  class LetterScheme
    def letter(piece)
      alphabet[piece.piece_index]
    end

    def for_letter(part_type, desired_letter)
      part_type::ELEMENTS.find { |e| letter(e) == desired_letter }
    end
  end

  class DefaultLetterScheme < LetterScheme
    def alphabet
      @alphabet ||= "a".upto("x").to_a
    end

    # Letters that we shoot to by default.
    def shoot_letters(part_type)
      ['a', 'b', 'd', 'l', 'h', 't', 'p']
    end
  end
end
