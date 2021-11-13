# frozen_string_literal: true

require 'twisty_puzzles'

# Controller that allows retrieval of parts of the cube.
# Technically this is not needed because its constant, but for the time being, the
# frontend is pretty thin and the backend handles everything, so this comes from the
# backend. This will probably be removed in the future though.
class PartTypesController < ApplicationController
  before_action :set_mode_type, only: [:show]

  include TwistyPuzzles::Utils::StringHelper
  
  # GET /api/parts.json
  def index
    respond_to do |format|
      format.json do
        part_types = (TwistyPuzzles::PART_TYPES - [TwistyPuzzles::Face]).map do |p|
          {name: simple_class_name(p), parts: p::ELEMENTS.map(&:to_s)}
        end
        render json: part_types
      end
    end
  end
end
