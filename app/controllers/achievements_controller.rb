# frozen_string_literal: true

# Controller that allows retrieval of achievements. Note that it does NOT include which users have them.
class AchievementsController < ApplicationController
  before_action :set_achievement, only: [:show]

  # GET /achievements
  # GET /achievements.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: Achievement::ALL.map(&:to_simple) }
    end
  end

  # GET /achievements/mode_created
  # GET /achievements/mode_created.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @achievement.to_simple }
    end
  end

  private

  def set_achievement
    head(:not_found) unless @achievement = Achievement.find_by_key(params[:id])
  end
end
