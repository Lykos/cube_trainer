# frozen_string_literal: true

# Controller for stats that a user had for one training mode.
class StatsController < ApplicationController
  before_action :set_mode
  before_action :set_stat, only: %i[show destroy]
  before_action :check_current_user_owns

  # GET /modes/1/stats
  # GET /modes/1/stats.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json do
        stats = @mode.stats.map(&:to_simple)
        render json: stats, status: :ok
      end
    end
  end

  # GET /modes/1/stats/1
  # GET /modes/1/stats/1.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @stat.to_simple, status: :ok }
    end
  end

  # DELETE /modes/1/stats/1.json
  def destroy
    if @stat.destroy
      head :no_content
    else
      render json: @stat.errors, status: :unprocessable_entity
    end
  end

  private

  def set_stat
    head :not_found unless (@stat = Stat.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = Mode.find_by(id: params[:mode_id]))
  end

  def owner
    @mode.user
  end
end
