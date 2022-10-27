# frozen_string_literal: true

# Controller for alg overrides that a user had for one training session.
class AlgOverridesController < ApplicationController
  before_action :set_training_session
  before_action :set_alg_override, only: %i[show update destroy]
  before_action :set_new_alg_override, only: %i[create]

  # GET /api/training_sessions/1/alg_overrides.json
  def index
    alg_overrides = @training_session.alg_overrides
                                     .order(created_at: :desc)
                                     .limit(params[:limit])
                                     .offset(params[:offset])

    render json: alg_overrides, status: :ok
  end

  # POST /api/training_sessions/1/alg_overrides.json
  def show
    render json: @alg_override, status: :ok
  end

  # GET /api/training_sessions/1/alg_overrides/1.json
  def create
    if @alg_override.save
      render json: @alg_override, status: :ok
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/training_sessions/1/alg_overrides/1.json
  def update
    if @alg_override.update(alg_override_params)
      render json: @alg_override, status: :ok
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/training_sessions/1/alg_overrides/1.json
  def destroy
    if @alg_override.destroy
      head :no_content
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  private

  def set_new_alg_override
    @alg_override = @training_session.alg_overrides.new(alg_override_params)
    render json: @alg_override.errors, status: :bad_request unless @alg_override.valid?
  end

  def set_alg_override
    @alg_override = @training_session.alg_overrides.find_by(id: params[:id])
    head :not_found unless @alg_override
  end

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:training_session_id])
    head :not_found unless @training_session
  end

  def alg_override_params
    fixed_params = params.require(:alg_override).permit(
      :case_key, :alg
    )
    if fixed_params[:case_key]
      fixed_params[:casee] =
        Types::CaseType.new.cast(fixed_params[:case_key])
    end
    fixed_params.delete(:case_key)
    fixed_params
  end
end
