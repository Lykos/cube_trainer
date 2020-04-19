# frozen_string_literal: true

# Active record type for achievements.
class AchievementType < ActiveRecord::Type::String
  def cast(value)
    return if value.nil?
    return value if value.is_a?(Achievement)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

    Achievement.find_by!(key: value)
  end

  def serialize(value)
    return if value.nil?

    value = cast(value) unless value.is_a?(Achievement)

    value.key
  end
end
