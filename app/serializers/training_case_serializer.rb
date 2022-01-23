# frozen_string_literal: true

# Serializer for training cases.
class TrainingCaseSerializer < ActiveModel::Serializer
  include CaseAttributeSerializer

  attributes :setup, :alg, :alg_source

  def alg_source
    return unless object.alg
    return { tag: :overridden, alg_override_id: object.alg.id } if object.alg.is_a?(AlgOverride)

    { tag: alg_tag(object.alg) }
  end

  def alg_tag(alg)
    raise TypeError unless object.alg.is_a?(Alg)

    return :inferred if alg.is_inferred
    return :fixed if alg.is_fixed

    :original
  end

  def setup
    object.setup&.to_s
  end

  def alg
    object.alg&.commutator&.to_s
  end
end
