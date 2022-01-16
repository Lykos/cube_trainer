# frozen_string_literal: true

# Serializer for users.
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :admin
end
