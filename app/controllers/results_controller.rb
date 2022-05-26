# frozen_string_literal: true

# Controller for results that a user had for one training session.
class ResultsController < ApplicationController
  before_action :set_training_session
  before_action :set_result, only: %i[show update destroy]
  before_action :set_new_result, only: %i[create]

  # GET /api/training_sessions/1/results.json
  def index
    results = @training_session.results
                               .order(created_at: :desc)
                               .limit(params[:limit])
                               .offset(params[:offset])
    render json: results, status: :ok
  end

  # POST /api/training_sessions/1/results/1.json
  def create
    if !@result.valid?
      render json: @result.errors, status: :bad_request
    elsif @result.save
      render json: @result, status: :ok
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  # GET /api/training_sessions/1/results/1.json
  def show
    render json: @result, status: :ok
  end

  # PATCH/PUT /api/training_sessions/1/results/1.json
  def update
    if @result.update(result_params)
      render json: @result, status: :ok
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/training_sessions/1/results/1.json
  def destroy
    if @result.destroy
      head :no_content
    else
      render json: @result.errors, status: :unprocessable_entity
    end
  end

  private

  def set_new_result
    @result = @training_session.results.new(result_params)
  end

  def set_result
    head :not_found unless (@result = @training_session.results.find_by(id: params[:id]))
  end

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:training_session_id])
    head :not_found unless @training_session
  end

  def result_params
    fixed_params = params.require(:result).permit(
      :case_key, :time_s, :failed_attempts, :word, :success,
      :num_hints
    )
    if fixed_params[:case_key]
      fixed_params[:casee] =
        Types::CaseType.new.cast(fixed_params[:case_key])
    end
    fixed_params.delete(:case_key)
    fixed_params
  end
end
