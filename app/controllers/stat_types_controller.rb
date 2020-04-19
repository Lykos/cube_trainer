# frozen_string_literal: true

# Controller that allows retrieval of stats.
# Note that it does NOT include which modes have them.
class StatsController < ApplicationController
  before_action :set_stat, only: [:show]

  # GET /stats
  # GET /stats.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: Stat::ALL.map(&:to_simple) }
    end
  end

  # GET /stats/mode_created
  # GET /stats/mode_created.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @stat.to_simple }
    end
  end

  private

  def set_stat
    head(:not_found) unless (@stat = Stat.find_by(key: params[:id]))
  end
end
