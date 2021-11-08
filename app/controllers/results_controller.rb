# frozen_string_literal: true

# Controller for results that a user had for one training mode.
class ResultsController < ApplicationController
  before_action :set_mode
  before_action :set_input, only: %i[show update destroy]
  before_action :check_current_user_owns

  # GET /api/modes/1/results
  # GET /api/modes/1/results.json
  def index
    results = @mode.inputs
                .joins(:result)
                .includes(:result)
                .order(created_at: :desc)
                .limit(params[:limit])
                .offset(params[:offset])
                .map(&:to_simple_result)
    render json: results, status: :ok
  end

  # GET /api/modes/1/results/1
  # GET /api/modes/1/results/1.json
  def show
    render json: @input.to_simple_result, status: :ok
  end

  # PATCH/PUT /api/modes/1/results/1.json
  def update
    if @input.result.update(result_params)
      render json: @input.to_simple_result, status: :ok
    else
      render json: @input.result.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/modes/1/results/1.json
  def destroy
    if @input.destroy
      head :no_content
    else
      render json: @input.errors, status: :unprocessable_entity
    end
  end

  private

  def set_input
    head :not_found unless (@input = Result.find_by(id: params[:id])&.input)
  end

  def set_mode
    head :not_found unless (@mode = Mode.find_by(id: params[:mode_id]))
  end

  def result_params
    params.require(:result).permit(:time_s, :failed_attempts, :word, :success, :num_hints)
  end

  def owner
    @mode.user
  end
end
