# frozen_string_literal: true

# Controller that allows retrieval of achievements.
# Note that it does NOT include which users have them.
# TODO: Remove now that it exists in the frontend.
class AchievementsController < ApplicationController
  before_action :set_achievement, only: [:show]

  # The achievements that exist are constant and public, so no authorization is required.
  # Note that the assignment of the achievements to users is not public, but this is not
  # handled by this controller.
  skip_before_action :authenticate_user!, only: %i[index show]

  # GET /api/achievements
  def index
    render json: Achievement::ALL
  end

  # GET /api/achievements/mode_created
  def show
    render json: @achievement
  end

  private

  def set_achievement
    head :not_found unless (@achievement = Achievement.find_by(id: params[:id]))
  end
end
