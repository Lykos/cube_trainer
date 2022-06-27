# frozen_string_literal: true

# Serializer for training sessions that is meant for lists of training sessions.
class TrainingSessionSummarySerializer < ActiveModel::Serializer
  attributes :id, :name, :num_results
end
