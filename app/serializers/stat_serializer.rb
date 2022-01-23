# frozen_string_literal: true

# Serializer for stats.
class StatSerializer < ActiveModel::Serializer
  attributes :id, :index, :created_at, :stat_type
end
