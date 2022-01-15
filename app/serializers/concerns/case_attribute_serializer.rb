module CaseAttributeSerializer
  extend ActiveSupport::Concern

  included do
    attributes :case_key, :case_name
  end

  def case_key
    CaseType.new.serialize(object.casee)
  end

  def case_name
    object.owning_set.case_name(object.casee)
  end
end
