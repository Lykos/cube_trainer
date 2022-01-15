class TrainingCaseSerializer < ActiveModel::Serializer
  include CaseAttributeSerializer

  attributes :setup, :alg

  def setup
    object.setup.to_s
  end

  def alg
    object.alg.to_s
  end
end
