# frozen_string_literal: true

require 'twisty_puzzles'

# Controller that allows retrieval of parts of the cube.
# Technically this is not needed because its constant, but for the time being, the
# frontend is pretty thin and the backend handles everything, so this comes from the
# backend. This will probably be removed in the future though.
class PartTypesController < ApplicationController
  include TwistyPuzzles::Utils::StringHelper
  include PartHelper

  # The part types that exist are constant and public, so no authorization is required.
  skip_before_action :authenticate_user!, only: %i[index]
  skip_before_action :check_current_user_can_read, only: %i[index]
  skip_before_action :check_current_user_can_write, only: %i[index]

  # GET /api/parts
  def index
    part_types =
      (TwistyPuzzles::PART_TYPES - [TwistyPuzzles::Face]).map do |p|
        parts = p::ELEMENTS.map { |e| part_to_simple(e) }
        { name: simple_class_name(p), parts: parts }
      end
    render json: part_types
  end
end
