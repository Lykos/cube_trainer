# frozen_string_literal: true

# Controller that allows retrieval of achievement grants (i.e. which user has which achievements).
class AchievementGrantsController < ApplicationController
  prepend_before_action :set_user
  before_action :set_achievement_grant, only: [:show]

  # GET /api/user/1/achievement_grants
  def index
    render json: @user.achievement_grants.map(&:to_simple)
  end

  # GET /api/user/1/achievement_grants/1
  def show
    render json: @achievement_grant.to_simple
  end

  private

  def set_user
    head :not_found unless (@user = User.find_by(id: params[:user_id]))
  end

  def set_achievement_grant
    head :not_found unless (@achievement_grant = @user.achievement_grants.find_by(id: params[:id]))
  end

  def owner
    @user
  end
end
