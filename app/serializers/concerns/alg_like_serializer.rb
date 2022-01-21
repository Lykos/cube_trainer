# frozen_string_literal: true

# Concern for serializers of classes that behave like and alg that solves
# one particular case. E.g. the edge commutator [M', U2] for the case UF DF UB.
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
