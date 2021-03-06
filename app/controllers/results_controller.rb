# frozen_string_literal: true

# Controller for results that a user had for one training mode.
class ResultsController < ApplicationController
  before_action :set_mode
  before_action :set_input, only: %i[show destroy]
  before_action :check_current_user_owns

  # GET /modes/1/results
  # GET /modes/1/results.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json do
        results = @mode.inputs
                       .joins(:result)
                       .includes(:result)
                       .order(created_at: :desc)
                       .limit(params[:limit])
                       .offset(params[:offset])
                       .map(&:to_simple_result)
        render json: results, status: :ok
      end
    end
  end

  # GET /modes/1/results/1
  # GET /modes/1/results/1.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @input.to_simple_result, status: :ok }
    end
  end

  # DELETE /modes/1/results/1.json
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

  def owner
    @mode.user
  end
end
