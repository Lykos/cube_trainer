# frozen_string_literal: true

# Controller for returning the cases of a training session.
class CasesController < ApplicationController
  before_action :set_training_session
  before_action :set_case, only: %i[show]

  # GET /api/training_sessions/2/cases
  def index
    render json: @training_session.cases.map(&:to_simple)
  end

  # GET /api/training_sessions/2/cases/3
  def show
    render json: @case.to_simple
  end

  private

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:training_session_id])
    head :not_found unless @training_session
  end

  def set_case
    head :not_found unless (@case = @training_session.cases.find { |c| c.id == params[:id] })
  end
end
