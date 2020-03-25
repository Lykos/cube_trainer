# frozen_string_literal: true

class CubeTrainer::Training::Input < ApplicationRecord
  attribute :mode, :symbol
  attribute :input_representation, :input_representation
end
