# frozen_string_literal: true

# Controller for training modes that the user created.
class ModesController < ApplicationController
  before_action :set_mode, only: %i[show update destroy]
  before_action :set_new_mode, only: %i[create]

  def name_exists_for_user?
    render json: current_user.modes.exists?(name: params[:mode_name]), status: :ok
  end

  # GET /api/modes
  def index
    render json: current_user.modes.map(&:to_simple)
  end

  # GET /api/modes/1
  def show
    render json: @mode.to_simple
  end

  # POST /api/modes.json
  def create
    if !@mode.valid?
      render json: @mode.errors, status: :bad_request
    elsif @mode.save
      render json: @mode.to_simple, status: :created
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/modes/1
  def update
    if @mode.update(mode_params)
      render json: @mode.to_simple, status: :ok
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
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:id]))
  end

  def set_new_mode
    @mode = current_user.modes.new(mode_params)
  end

  def owner
    @mode&.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    fixed_params = params
                   .require(:mode)
                   .permit(:name, :known, :show_input_mode, :goal_badness, :cube_size,
                           :memo_time_s, stat_types: [], buffer: [:key], mode_type: [:key],
                                         alg_set: [:id])
    fixed_params[:mode_type] = fixed_params[:mode_type][:key] if fixed_params[:mode_type]
    fixed_params[:buffer] = fixed_params[:buffer][:key] if fixed_params[:buffer]
    fixed_params[:alg_set_id] = fixed_params[:alg_set][:id] if fixed_params[:alg_set]
    fixed_params.delete(:alg_set)
    fixed_params
  end
end
