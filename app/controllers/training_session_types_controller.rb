# frozen_string_literal: true

# Controller that allows retrieval of training_session types.
# TrainingSession types are basic templates which users use to create their training sessions.
class TrainingSessionTypesController < ApplicationController
  before_action :set_mode_type, only: [:show]

  # The training_session types that exist are constant and public, so no authorization is required.
  # Note that the assignment of the training_sessions is not public, but this is not handled by
  # this controller.
  skip_before_action :authenticate_user!, only: %i[index show]

  # GET /api/mode_types
  def index
    render json: TrainingSessionType.all
  end

  # GET /api/mode_types/1
  def show
    render json: @mode_type
  end

  private

  def set_mode_type
    head :not_found unless (@mode_type = TrainingSessionType.find_by(id: params[:id]))
  end
end
