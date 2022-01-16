# frozen_string_literal: true

class StatSerializer < ActiveModel::Serializer
  attributes :id, :index, :created_at
  belongs_to :stat_type
end
