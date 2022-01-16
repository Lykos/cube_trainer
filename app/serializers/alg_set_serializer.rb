# frozen_string_literal: true

# Serializer for alg sets.
class AlgSetSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :owner, :buffer, :created_at

  def buffer
    object.buffer ? part_to_simple(object.buffer) : nil
  end
end
