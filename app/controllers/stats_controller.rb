# frozen_string_literal: true

# Controller for stats that a user had for one training session.
# TODO: Remove now that it exists in the frontend.
class StatsController < ApplicationController
  before_action :set_training_session
  before_action :set_stat, only: %i[show destroy]

  # GET /api/training_sessions/1/stats
  def index
    stats = @training_session.stats
    render json: stats, status: :ok
  end

  # GET /api/training_sessions/1/stats/1
  def show
    render json: @stat, status: :ok
  end

  # DELETE /api/training_sessions/1/stats/1
  def destroy
    if @stat.destroy
      head :no_content
    else
      render json: @stat.errors, status: :unprocessable_entity
    end
  end

  private

  def set_stat
    head :not_found unless (@stat = @training_session.stats.find_by(id: params[:id]))
  end

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:training_session_id])
    head :not_found unless @training_session
  end

  def owner
    @training_session.user
  end
end
