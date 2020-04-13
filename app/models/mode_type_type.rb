class ModeTypeType < ActiveRecord::Type::String
  MODE_TYPES_BY_NAME =
    ModeType::ALL.map { |v| [v.name, v] }.to_h.freeze

  def cast(value)
    return if value.nil?
    return value if value.is_a?(ModeType)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

    MODE_TYPES_BY_NAME[value.to_sym] || (raise ArgumentError)
  end

  def serialize(value)
    return if value.nil?
    raise TypeError unless value.is_a?(ModeType)

    value.name
  end
end
