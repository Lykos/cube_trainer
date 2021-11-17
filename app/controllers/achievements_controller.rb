# frozen_string_literal: true

# Controller that allows retrieval of achievements.
# Note that it does NOT include which users have them.
class AchievementsController < ApplicationController
  before_action :set_achievement, only: [:show]

  # The achievements that exist are constant and public, so no authorization is required.
  # Note that the assignment of the achievements to users is not public, but this is not
  # handled by this controller.
  skip_before_action :authenticate_user!, only: %i[index show]

  # GET /api/achievements
  def index
    render json: Achievement::ALL.map(&:to_simple)
  end

  # GET /api/achievements/mode_created
  def show
    render json: @achievement.to_simple
  end

  private

  def set_achievement
    head :not_found unless (@achievement = Achievement.find_by(key: params[:id]))
  end
end
