class LetterSchemeSerializer < ActiveModel::Serializer
  attributes :id, :wing_lettering_mode, :xcenters_like_corners, :tcenters_like_edges, :midges_like_edges
  has_many :mappings
end
