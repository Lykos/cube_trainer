# frozen_string_literal: true

class StatTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
