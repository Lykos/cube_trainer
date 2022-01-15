class LetterSchemeMappingSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :letter, :part, :created_at

  def part
    part_to_simple(object.part)
  end
end
