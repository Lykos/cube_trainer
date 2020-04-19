# frozen_string_literal: true

# Active record type for mode types.
class AchievementTypeType < ActiveRecord::Type::String
  def cast(value)
    return if value.nil?
    return value if value.is_a?(AchievementType)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

    AchievementType::BY_NAME[value.to_sym] || (raise ArgumentError)
  end

  def serialize(value)
    return if value.nil?
    raise TypeError unless value.is_a?(AchievementType)

    value.name
  end
end
