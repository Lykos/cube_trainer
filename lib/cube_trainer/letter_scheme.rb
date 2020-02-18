# frozen_string_literal: true

require 'cube_trainer/core/cube'

module CubeTrainer
  # Letter scheme that maps stickers to letters.
  class LetterScheme
    def initialize
      alphabet.each do |letter|
        raise "Uncanonical letter #{letter} in alphabet." if letter != canonicalize_letter(letter)
      end
    end

    def letter(piece)
      alphabet[piece.piece_index]
    end

    def for_letter(part_type, desired_letter)
      canonicalized_letter = canonicalize_letter(desired_letter)
      part_type::ELEMENTS.find { |e| letter(e) == canonicalized_letter }
    end

    def valid_letter?(letter)
      alphabet.include?(canonicalize_letter(letter))
    end

    def alphabet
      raise NotImplementedError
    end

    def canonicalize_letter(_letter)
      raise NotImplementedError
    end

    def parse_part(part_type, part_string)
      if valid_letter?(part_string)
        for_letter(part_type, part_string)
      else
        part_type.parse(part_string)
      end
    end

    alias parse_buffer parse_part
  end

  # Letter scheme used by Bernhard Brodowsky.
  class BernhardLetterScheme < LetterScheme
    def alphabet
      @alphabet ||= 'a'.upto('x').to_a
    end

    def canonicalize_letter(letter)
      letter.downcase
    end

    # Letters that we shoot to by default.
    def shoot_letters(_part_type)
      %w[a b d l h t p]
    end

    PART_TYPE_BUFFERS = {
      Core::Corner => Core::Corner.for_face_symbols(%i[U L B]),
      Core::Edge => Core::Edge.for_face_symbols(%i[U F]),
      Core::Wing => Core::Wing.for_face_symbols(%i[F U]),
      Core::XCenter => Core::XCenter.for_face_symbols(%i[U R F]),
      Core::TCenter => Core::TCenter.for_face_symbols(%i[U F])
    }.freeze

    def default_buffer(part_type)
      PART_TYPE_BUFFERS[part_type]
    end
  end
end
