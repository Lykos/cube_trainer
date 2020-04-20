# frozen_string_literal: true

# Controller for training modes that the user created.
# TODO: Make this a sub-resource of user
class ModesController < ApplicationController
  before_action :set_mode, only: %i[show update destroy]
  before_action :check_current_user_owns, only: %i[show update destroy]

  def name_exists_for_user?
    render json: current_user.modes.exists?(name: params[:mode_name]), status: :ok
  end

  # GET /modes
  # GET /modes.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: current_user.modes }
    end
  end

  # GET /modes/1
  # GET /modes/1.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @mode }
    end
  end

  # GET /modes/new
  def new
    render 'application/cube_trainer'
  end

  # GET /modes/1/edit
  def edit
    render 'application/cube_trainer'
  end

  # POST /modes.json
  def create
    @mode = current_user.modes.new(mode_params)

    if !@mode.valid?
      render json: @mode, status: :bad_request
    elsif @mode.save
      render json: @mode, status: :created
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /modes/1.json
  def update
    if @mode.update(mode_params)
      render json: @mode, status: :ok
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # DELETE /modes/1.json
  def destroy
    if @mode.destroy
      head :no_content
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  private

  def set_mode
    head :not_found unless (@mode = Mode.find_by(id: params[:id]))
  end

  def owner
    @mode.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params
      .require(:mode)
      .permit(:name, :known, :mode_type, :show_input_mode, :buffer, :goal_badness, :cube_size, stat_types: [])
  end
end
