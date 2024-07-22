# frozen_string_literal: true

# Serializer for letter schemes.
class LetterSchemeSerializer < ActiveModel::Serializer
  attributes :id, :wing_lettering_mode, :xcenters_like_corners, :tcenters_like_edges,
             :midges_like_edges, :invert_wing_letter, :invert_twists, :created_at
  has_many :mappings
end
