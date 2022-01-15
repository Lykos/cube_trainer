# frozen_string_literal: true

# Active record type for stat_type.
class StatTypeType < ActiveRecord::Type::String
  def cast(value)
    return if value.nil?
    return value if value.is_a?(StatType)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

    StatType.find_by(id: value)
  end

  def serialize(value)
    return if value.nil?

    value = cast(value) unless value.is_a?(StatType)
    value.id
  end
end
