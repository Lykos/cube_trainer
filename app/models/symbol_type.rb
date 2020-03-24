class SymbolType < ActiveRecord::Type::String
  def cast(value)
    value&.to_sym
  end

  def serialize(value)
    value&.to_s
  end
end
