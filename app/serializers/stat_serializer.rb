# frozen_string_literal: true

# TODO: Remove now that it exists in the frontend.
class StatSerializer < ActiveModel::Serializer
  attributes :id, :index, :created_at
  belongs_to :stat_type
end
