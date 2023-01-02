# frozen_string_literal: true

# A serialize for achievement grants that only serializes relevant attributes.
class ResultSerializer < ActiveModel::Serializer
  include CaseAttributeSerializer

  attributes :id, :time_s, :failed_attempts, :word, :success, :num_hints, :created_at
end
