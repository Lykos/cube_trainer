class AchievementsController < ApplicationController
  before_action :set_achievement, only: [:show, :update, :destroy]

  # GET /achievements
  # GET /achievements.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: Achievement.all }
    end
  end

  # GET /achievements/1
  # GET /achievements/1.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @achievement }
    end
  end

  # GET /achievements/new
  def new
    render 'application/empty'
  end

  # GET /achievements/1/edit
  def edit
    render 'application/empty'
  end

  # POST /achievements.json
  def create
    @achievement = Achievement.new(achievement_params)

    if !@achievement.valid?
      render json: @achievement, status: :bad_request
    elsif @achievement.save
      render json: @achievement, status: :created
    else
      render json: @achievement.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /achievements/1.json
  def update
    if @achievement.update(achievement_params)
      render json: @achievement, status: :ok
    else
      render json: @achievement.errors, status: :unprocessable_entity
    end
  end

  # DELETE /achievements/1.json
  def destroy
    if @achievement.destroy
      head :no_content
    else 
      render json: @achievement.errors, status: :unprocessable_entity
    end
  end

  private

  def set_achievement
    head :not_found unless @achievement = Achievement.find_by(id: params[:id])
  end

  def achievement_params
    params.require(:achievement).permit(:name, :achievement_type, :param)
  end
end
