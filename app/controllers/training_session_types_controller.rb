# frozen_string_literal: true

# Controller that allows retrieval of mode types.
# TrainingSession types are basic templates which users use to create their training modes.
class TrainingSessionTypesController < ApplicationController
  before_action :set_mode_type, only: [:show]

  # The mode types that exist are constant and public, so no authorization is required.
  # Note that the assignment of the modes is not public, but this is not handled by
  # this controller.
  skip_before_action :authenticate_user!, only: %i[index show]

  # GET /api/mode_types
  def index
    render json: TrainingSessionType.all.map(&:to_simple)
  end

  # GET /api/mode_types/1
  def show
    render json: @mode_type.to_simple
  end

  private

  def set_mode_type
    head :not_found unless (@mode_type = TrainingSessionType.find_by(key: params[:id]))
  end
end
