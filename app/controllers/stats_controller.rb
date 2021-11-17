# frozen_string_literal: true

# Controller for stats that a user had for one training mode.
class StatsController < ApplicationController
  before_action :set_mode
  before_action :set_stat, only: %i[show destroy]

  # GET /api/modes/1/stats
  def index
    stats = @mode.stats.map(&:to_simple)
    render json: stats, status: :ok
  end

  # GET /api/modes/1/stats/1
  def show
    render json: @stat.to_simple, status: :ok
  end

  # DELETE /api/modes/1/stats/1
  def destroy
    if @stat.destroy
      head :no_content
    else
      render json: @stat.errors, status: :unprocessable_entity
    end
  end

  private

  def set_stat
    head :not_found unless (@stat = @mode.stats.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def owner
    @mode.user
  end
end
