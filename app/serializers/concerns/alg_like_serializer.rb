module AlgLikeSerializer
  extend ActiveSupport::Concern
  include CaseAttributeSerializer

  included do
    attributes :id, :alg
  end

  def alg
    object.alg.to_s
  end
end
