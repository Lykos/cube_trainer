# frozen_string_literal: true

# Controller that allows retrieval of achievement grants (i.e. which user has which achievements).
class AchievementGrantsController < ApplicationController
  before_action :set_user
  before_action :check_current_user_owns
  before_action :set_achievement_grant, only: [:show]

  # GET /user/1/achievement_grants
  # GET /user/1/achievement_grants.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @user.achievement_grants.map(&:to_simple) }
    end
  end

  # GET /user/1/achievement_grants/1
  # GET /user/1/achievement_grants/1.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @achievement_grant.to_simple }
    end
  end

  private

  def set_user
    head(:not_found) unless @user = User.find_by(id: params[:user_id])
  end

  def set_achievement_grant
    head(:not_found) unless @achievement_grant = @user.achievement_grants.find_by(id: params[:id])
  end

  def owner
    @user
  end
end
