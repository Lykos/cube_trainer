class ModeTypeType < ActiveRecord::Type::String
  include CubeTrainer::Training::CommutatorTypes

  COMMUTATOR_INFOS_BY_MODE_TYPE_NAME =
    COMMUTATOR_TYPES.values.map { |v| [v.result_symbol, v] }.to_h.freeze

  def cast(value)
    return if value.nil?
    return value if value.is_a?(CommutatorInfo)
    raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

    COMMUTATOR_INFOS_BY_MODE_TYPE_NAME[value.to_sym] || (raise ArgumentError)
  end

  def serialize(value)
    return if value.nil?
    raise TypeError unless value.is_a?(CommutatorInfo)

    value.name
  end
end
