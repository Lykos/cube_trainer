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

    def parse_part(part_type, part_string)
      if has_letter?(part_string)
        for_letter(part_type, part_string)
      else
        part_type.parse(part_string)
      end
    end

    alias parse_buffer parse_part

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

    PART_TYPE_BUFFERS = {
      Corner => Corner.for_colors([:yellow, :blue, :orange]),
      Edge => Edge.for_colors([:yellow, :red]),
      Wing => Wing.for_colors([:red, :yellow]),
      XCenter => XCenter.for_colors([:yellow, :green, :red]),
      TCenter => TCenter.for_colors([:yellow, :red])
    }

    def default_buffer(part_type)
      PART_TYPE_BUFFERS[part_type]
    end
  end
end
