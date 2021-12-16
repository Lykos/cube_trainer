# frozen_string_literal: true

# Controller for results that a user had for one training mode.
class ResultsController < ApplicationController
  before_action :set_mode
  before_action :set_result, only: %i[show update destroy]
  before_action :set_new_result, only: %i[create]

  # GET /api/modes/1/results.json
  def index
    results = @mode.results
                   .order(created_at: :desc)
                   .limit(params[:limit])
                   .offset(params[:offset])
                   .map(&:to_simple)
    render json: results, status: :ok
  end

  # POST /api/modes/1/results/1.json
  def create
    if !@result.valid?
      render json: @result.errors, status: :bad_request
    elsif @result.save
      render json: @result.to_simple, status: :ok
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  # GET /api/modes/1/results/1.json
  def show
    render json: @result.to_simple, status: :ok
  end

  # PATCH/PUT /api/modes/1/results/1.json
  def update
    if @result.update(result_params)
      render json: @result.to_simple, status: :ok
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

  def set_new_result    
    @result = @mode.results.new(result_params)
  end

  def set_result    
    head :not_found unless (@result = @mode.results.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def result_params
    params.require(:result).permit(:case_key, :time_s, :failed_attempts, :word, :success, :num_hints)
  end
end
