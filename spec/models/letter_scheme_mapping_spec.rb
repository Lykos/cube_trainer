# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LetterSchemeMapping, type: :model do
  include_context 'with user abc'
  let(:letter_scheme) do
    letter_scheme = LetterScheme.find_or_initialize_by(user: user)
    letter_scheme.mappings.clear
    letter_scheme.save!
    letter_scheme
  end
  let(:part) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:other_part) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }

  describe '#valid?' do
    it 'returns false if the letter is an empty string' do
      expect(letter_scheme.mappings.new(part: part, letter: '')).not_to be_valid
    end

    it 'returns false if the letter is a string with multiple characters' do
      expect(letter_scheme.mappings.new(part: part, letter: 'as')).not_to be_valid
    end

    it 'returns false if the part is not unique' do
      letter_scheme.mappings.create!(part: part, letter: 'a')
      expect(letter_scheme.mappings.new(part: part, letter: 'b')).not_to be_valid
    end
  end
end
