# frozen_string_literal: true

# Controller for alg overrides that a user had for one training mode.
class AlgOverridesController < ApplicationController
  before_action :set_mode
  before_action :set_alg_override, only: %i[show update destroy]
  before_action :set_new_alg_override, only: %i[create]

  # GET /api/modes/1/alg_overrides.json
  def index
    alg_overrides = @mode.alg_overrides
                      .order(created_at: :desc)
                      .limit(params[:limit])
                      .offset(params[:offset])
                      .map(&:to_simple)
    render json: alg_overrides, status: :ok
  end

  # POST /api/modes/1/alg_overrides/create_or_update.json
  def create_or_update
    @alg_override = @mode.alg_overrides.find_by(case_key: InputRepresentationType.new.cast(params[:case_key]))
    if @alg_override
      update
    else
      set_new_alg_override
      @alg_override.valid? && create
    end
  end

  # POST /api/modes/1/alg_overrides.json
  def create
    if @alg_override.save
      render json: @alg_override.to_simple, status: :ok
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  # GET /api/modes/1/alg_overrides/1.json
  def show
    render json: @alg_override.to_simple, status: :ok
  end

  # PATCH/PUT /api/modes/1/alg_overrides/1.json
  def update
    if @alg_override.update(alg_override_params)
      render json: @alg_override.to_simple, status: :ok
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/modes/1/alg_overrides/1.json
  def destroy
    if @alg_override.destroy
      head :no_content
    else
      render json: @alg_override.errors, status: :unprocessable_entity
    end
  end

  private

  def set_new_alg_override
    @alg_override = @mode.alg_overrides.new(alg_override_params)
    render json: @alg_override.errors, status: :bad_request unless @alg_override.valid?
  end

  def set_alg_override
    head :not_found unless (@alg_override = @mode.alg_overrides.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def alg_override_params
    params.require(:alg_override).permit(
      :case_key, :alg
    )
  end
end
