# frozen_string_literal: true

# Controller that allows retrieval of stat types.
# Note that it does NOT include which modes have them.
class StatTypesController < ApplicationController
  before_action :set_stat_type, only: [:show]

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
