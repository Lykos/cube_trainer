# frozen_string_literal: true

# Serializer for training cases.
class TrainingCaseSerializer < ActiveModel::Serializer
  include CaseAttributeSerializer

  attributes :setup, :alg, :alg_source

  def alg_source
    return unless object.alg
    return { tag: :overridden, alg_override_id: object.alg.id } if object.alg.is_a?(AlgOverride)
    raise TypeError unless object.alg.is_a?(Alg)

    tag = object.alg.is_fixed ? :fixed : :original
    { tag: tag }
  end

  def setup
    object.setup&.to_s
  end

  def alg
    object.alg&.algorithm&.to_s
  end
end
