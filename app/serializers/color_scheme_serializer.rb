# frozen_string_literal: true

# Serializer for color schemes.
class ColorSchemeSerializer < ActiveModel::Serializer
  attributes :id, :color_u, :color_f, :setup

  def setup
    object.setup.to_s
  end
end
