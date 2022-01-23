# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LetterScheme, type: :model do
  include_context 'with edges'
  include_context 'with user abc'

  subject(:letter_scheme) do
    described_class.new(
      user: user,
      letter_scheme_mappings_attributes: [{ part: 'Edge:UF', letter: 'a' }, { part: 'Edge:FU', letter: 'e' }, { part: 'Corner:URF', letter: 'b' }, { part: 'Corner:FUR', letter: 'f' }]
    )
  end

  describe '#letter' do
    it 'returns the configured letter for an edge' do
      expect(letter_scheme.letter(uf)).to eq('a')
      expect(letter_scheme.letter(fu)).to eq('e')
    end

    it 'returns the configured letter for a corner' do
      expect(letter_scheme.letter(TwistyPuzzles::Corner.for_face_symbols(%i[U F R]))).to eq('b')
    end

    it 'returns nil in case of no configured letter' do
      expect(letter_scheme.letter(ub)).to be_nil
      expect(letter_scheme.letter(TwistyPuzzles::Corner.for_face_symbols(%i[U L B]))).to be_nil
      expect(letter_scheme.letter(TwistyPuzzles::Midge.for_face_symbols(%i[U F]))).to be_nil
      expect(letter_scheme.letter(TwistyPuzzles::TCenter.for_face_symbols(%i[U F]))).to be_nil
      expect(letter_scheme.letter(TwistyPuzzles::XCenter.for_face_symbols(%i[U F R]))).to be_nil
      expect(letter_scheme.letter(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))).to be_nil
    end

    it 'returns the corresponding letter for a midge' do
      letter_scheme.midges_like_edges = true
      expect(letter_scheme.letter(TwistyPuzzles::Midge.for_face_symbols(%i[U F]))).to eq('a')
    end

    it 'returns the corresponding letter for a T-center' do
      letter_scheme.tcenters_like_edges = true
      expect(letter_scheme.letter(TwistyPuzzles::TCenter.for_face_symbols(%i[U F]))).to eq('a')
    end

    it 'returns the corresponding letter for an X-center' do
      letter_scheme.xcenters_like_corners = true
      expect(letter_scheme.letter(TwistyPuzzles::XCenter.for_face_symbols(%i[U F R]))).to eq('b')
    end

    it 'returns the corresponding letter for a wing like an inverted edge' do
      letter_scheme.wing_lettering_mode = :like_edges
      letter_scheme.invert_wing_letter = true
      expect(letter_scheme.letter(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))).to eq('a')
    end

    it 'returns the corresponding letter for a wing like an edge' do
      letter_scheme.wing_lettering_mode = :like_edges
      letter_scheme.invert_wing_letter = false
      expect(letter_scheme.letter(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))).to eq('e')
    end

    it 'returns the corresponding letter for a wing like an inverted corner' do
      letter_scheme.wing_lettering_mode = :like_corners
      letter_scheme.invert_wing_letter = true
      expect(letter_scheme.letter(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))).to eq('b')
    end

    it 'returns the corresponding letter for a wing like a corner' do
      letter_scheme.wing_lettering_mode = :like_corners
      letter_scheme.invert_wing_letter = false
      expect(letter_scheme.letter(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))).to eq('f')
    end
  end

  describe '#for_letter' do
    it 'returns the configured edge for a letter' do
      expect(letter_scheme.letter(uf)).to eq('a')
      expect(letter_scheme.letter(fu)).to eq('e')
    end

    it 'returns the configured corner for a letter' do
      expect(letter_scheme.for_letter(TwistyPuzzles::Corner, 'b')).to eq(TwistyPuzzles::Corner.for_face_symbols(%i[U F R]))
    end

    it 'returns nil in case of no configured letter' do
      expect(letter_scheme.for_letter(TwistyPuzzles::Edge, 'b')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::Corner, 'a')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::Midge, 'a')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::TCenter, 'a')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::XCenter, 'b')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'a')).to be_nil
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'b')).to be_nil
    end

    it 'returns the corresponding letter for a midge' do
      letter_scheme.midges_like_edges = true
      expect(letter_scheme.for_letter(TwistyPuzzles::Midge, 'a')).to eq(TwistyPuzzles::Midge.for_face_symbols(%i[U F]))
    end

    it 'returns the corresponding letter for a T-center' do
      letter_scheme.tcenters_like_edges = true
      expect(letter_scheme.for_letter(TwistyPuzzles::TCenter, 'a')).to eq(TwistyPuzzles::TCenter.for_face_symbols(%i[U F]))
    end

    it 'returns the corresponding letter for an X-center' do
      letter_scheme.xcenters_like_corners = true
      expect(letter_scheme.for_letter(TwistyPuzzles::XCenter, 'b')).to eq(TwistyPuzzles::XCenter.for_face_symbols(%i[U F R]))
    end

    it 'returns the corresponding letter for a wing like an inverted edge' do
      letter_scheme.wing_lettering_mode = :like_edges
      letter_scheme.invert_wing_letter = true
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'a')).to eq(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))
    end

    it 'returns the corresponding letter for a wing like an edge' do
      letter_scheme.wing_lettering_mode = :like_edges
      letter_scheme.invert_wing_letter = false
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'e')).to eq(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))
    end

    it 'returns the corresponding letter for a wing like an inverted corner' do
      letter_scheme.wing_lettering_mode = :like_corners
      letter_scheme.invert_wing_letter = true
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'b')).to eq(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))
    end

    it 'returns the corresponding letter for a wing like a corner' do
      letter_scheme.wing_lettering_mode = :like_corners
      letter_scheme.invert_wing_letter = false
      expect(letter_scheme.for_letter(TwistyPuzzles::Wing, 'f')).to eq(TwistyPuzzles::Wing.for_face_symbols(%i[U F R]))
    end
  end
end
