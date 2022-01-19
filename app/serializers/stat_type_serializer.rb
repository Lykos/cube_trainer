# frozen_string_literal: true

# TODO: Remove now that it exists in the frontend.
class StatTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
