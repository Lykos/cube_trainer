# frozen_string_literal: true

# Controller that allows retrieval of stat types.
# Note that it does NOT include which training_sessions have them.
class StatTypesController < ApplicationController
  before_action :set_stat_type, only: [:show]

  # The stats types that exist are constant and public, so no authorization is required.
  # Note that the assignment of the stats is not public, but this is not handled by
  # this controller.
  skip_before_action :authenticate_user!, only: %i[index show]

  # GET /stat_types
  # GET /stat_types.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: StatType::ALL.map(&:to_simple) }
    end
  end

  # GET /stat_types/mode_created
  # GET /stat_types/mode_created.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @stat_type.to_simple }
    end
  end

  private

  def set_stat_type
    head :not_found unless (@stat_type = StatType.find_by(key: params[:id]))
  end
end
