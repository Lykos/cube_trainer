class AlgSetSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :owner, :buffer

  def buffer
    object.buffer ? part_to_simple(object.buffer) : nil
  end
end
