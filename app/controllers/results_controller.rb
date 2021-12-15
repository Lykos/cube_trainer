# frozen_string_literal: true

# Controller for results that a user had for one training mode.
class ResultsController < ApplicationController
  before_action :set_mode
  before_action :set_result, only: %i[show update destroy]

  # GET /api/modes/1/results.json
  def index
    results = @mode.results
                   .order(created_at: :desc)
                   .limit(params[:limit])
                   .offset(params[:offset])
                   .map(&:to_simple_result)
    render json: results, status: :ok
  end

  # GET /api/modes/1/results/1.json
  def show
    render json: @result.to_simple_result, status: :ok
  end

  # PATCH/PUT /api/modes/1/results/1.json
  def update
    if @result.result.update(result_params)
      render json: @result.to_simple_result, status: :ok
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/modes/1/results/1.json
  def destroy
    if @result.destroy
      head :no_content
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  private

  def set_result    
    head :not_found unless (@result = @mode.results.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def result_params
    params.require(:result).permit(:representation, :time_s, :failed_attempts, :word, :success, :num_hints)
  end
end
