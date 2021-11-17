# frozen_string_literal: true

# Controller that allows retrieval of achievement grants (i.e. which user has which achievements).
class AchievementGrantsController < ApplicationController
  before_action :set_achievement_grant, only: [:show]

  # GET /api/achievement_grants
  def index
    render json: current_user.achievement_grants.map(&:to_simple)
  end

  # GET /api/achievement_grants/1
  def show
    render json: @achievement_grant.to_simple
  end

  private

  def set_achievement_grant
    unless (@achievement_grant = current_user.achievement_grants.find_by(id: params[:id]))
      head :not_found
    end
  end
end
