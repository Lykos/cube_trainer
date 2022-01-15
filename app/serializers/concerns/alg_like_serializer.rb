module AlgLikeSerializer
  extend ActiveSupport::Concern
  include CaseAttributeSerializer

  included do
    attributes :id, :alg, :created_at
  end

  def alg
    object.alg.to_s
  end
end
