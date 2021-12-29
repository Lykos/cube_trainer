# frozen_string_literal: true

# Controller for training training_sessions that the user created.
class TrainingSessionsController < ApplicationController
  before_action :set_training_session, only: %i[show update destroy]
  before_action :set_new_training_session, only: %i[create]

  def name_exists_for_user?
    render json: current_user.training_sessions.exists?(name: params[:training_session_name]),
           status: :ok
  end

  # GET /api/training_sessions
  def index
    render json: current_user.training_sessions.map(&:to_simple)
  end

  # GET /api/training_sessions/1
  def show
    render json: @training_session.to_simple
  end

  # POST /api/training_sessions.json
  def create
    if !@training_session.valid?
      render json: @training_session.errors, status: :bad_request
    elsif @training_session.save
      render json: @training_session.to_simple, status: :created
    else
      render json: @training_session.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/training_sessions/1
  def update
    if @training_session.update(training_session_params)
      render json: @training_session.to_simple, status: :ok
    else
      render json: @training_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/training_sessions/1
  def destroy
    if @training_session.destroy
      head :no_content
    else
      render json: @training_session.errors, status: :unprocessable_entity
    end
  end

  private

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:id])
    head :not_found unless @training_session
  end

  def set_new_training_session
    @training_session = current_user.training_sessions.new(training_session_params)
  end

  def owner
    @training_session&.user
  end

  # Only allow a list of trusted parameters through.
  def training_session_params
    fixed_params = params
                   .require(:training_session)
                   .permit(:name, :known, :show_input_mode, :goal_badness, :cube_size,
                           :memo_time_s, stat_types: [], buffer: [:key],
                                         training_session_type: [:key], alg_set: [:id])
    if fixed_params[:training_session_type]
      fixed_params[:training_session_type] =
        fixed_params[:training_session_type][:key]
    end
    fixed_params[:buffer] = fixed_params[:buffer][:key] if fixed_params[:buffer]
    fixed_params[:alg_set_id] = fixed_params[:alg_set][:id] if fixed_params[:alg_set]
    fixed_params.delete(:alg_set)
    fixed_params
  end
end
