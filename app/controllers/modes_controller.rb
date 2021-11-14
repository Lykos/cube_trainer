# frozen_string_literal: true

# Controller for training modes that the user created.
class ModesController < ApplicationController
  prepend_before_action :set_mode, only: %i[show update destroy]
  prepend_before_action :set_new_mode, only: %i[create]

  # The owner is undefined for these actions, so the check wouldn't work.
  # But we select only the modes for this user, so the check isn't necessary.
  skip_before_action :check_current_user_can_read, only: %i[name_exists_for_user? index]
  skip_before_action :check_current_user_can_write, only: %i[name_exists_for_user? index]

  def name_exists_for_user?
    render json: current_user.modes.exists?(name: params[:mode_name]), status: :ok
  end

  # GET /api/modes
  def index
    render json: current_user.modes
  end

  # GET /api/modes/1
  def show
    render json: @mode
  end

  # POST /api/modes.json
  def create
    if !@mode.valid?
      render json: @mode, status: :bad_request
    elsif @mode.save
      render json: @mode, status: :created
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/modes/1
  def update
    if @mode.update(mode_params)
      render json: @mode, status: :ok
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/modes/1
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

  def set_new_mode
    @mode = current_user.modes.new(mode_params)
  end

  def owner
    @mode&.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params
      .require(:mode)
      .permit(:name, :known, :mode_type, :show_input_mode, :buffer, :goal_badness, :cube_size,
              :memo_time_s, stat_types: [])
  end
end
