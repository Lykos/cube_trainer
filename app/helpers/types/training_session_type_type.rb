# frozen_string_literal: true

module Types
  # Active record type for training_session types.
  class TrainingSessionTypeType < ActiveRecord::Type::String
    def cast(value)
      return if value.nil?
      return value if value.is_a?(TrainingSessionType)
      raise TypeError unless value.is_a?(String) || value.is_a?(Symbol)

      TrainingSessionType.find_by(id: value)
    end

    def serialize(value)
      return if value.nil?

      value = cast(value) unless value.is_a?(TrainingSessionType)
      value.id
    end
  end
end
