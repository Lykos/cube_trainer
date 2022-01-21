# frozen_string_literal: true

class ResultSerializer < ActiveModel::Serializer
  include CaseAttributeSerializer

  attributes :id, :time_s, :failed_attempts, :word, :success, :num_hints, :created_at
end
