# frozen_string_literal: true

# Concern for classes that have a case field and serialize it.
# Note that we can't use a regular case serializer as this needs a reference to the owning set.
module CaseAttributeSerializer
  extend ActiveSupport::Concern

  included do
    attribute :casee
  end

  def casee
    {
      key: case_key,
      name: case_name,
      raw_name: raw_case_name
    }
  end

  private

  def case_key
    CaseType.new.serialize(object.casee)
  end

  def case_name
    object.owning_set.case_name(object.casee)
  end

  def raw_case_name
    object.owning_set.raw_case_name(object.casee)
  end
end
