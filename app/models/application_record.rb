# frozen_string_literal: true

# Base class for the models of this Rails app.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
