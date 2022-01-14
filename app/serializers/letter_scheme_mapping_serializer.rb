class LetterSchemeMappingSerializer < ActiveModel::Serializer
  include PartHelper

  attributes :id, :letter, :part

  def part
    part_to_simple(object.part)
  end
end
