# frozen_string_literal: true

require 'cube_trainer/core/cube'

module CubeTrainer
  class LetterScheme
    def initialize
      alphabet.each do |letter|
        if letter != canonicalize_letter(letter)
          raise "Uncanonical letter #{letter} in alphabet."
                               end
      end
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

    def canonicalize_letter(_letter)
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
      Corner => Corner.for_face_symbols(%i[U L B]),
      Edge => Edge.for_face_symbols(%i[U F]),
      Wing => Wing.for_face_symbols(%i[F U]),
      XCenter => XCenter.for_face_symbols(%i[U R F]),
      TCenter => TCenter.for_face_symbols(%i[U F])
    }.freeze

    def default_buffer(part_type)
      PART_TYPE_BUFFERS[part_type]
    end
  end
end
