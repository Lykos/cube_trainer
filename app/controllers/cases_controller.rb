# frozen_string_literal: true

# Controller for returning the cases of a mode.
class CasesController < ApplicationController
  before_action :set_mode
  before_action :set_case, only: %i[show]

  # GET /api/modes/2/cases
  def index
    render json: @mode.cases.map(&:to_simple)
  end

  # GET /api/modes/2/cases/3
  def show
    render json: @case.to_simple
  end

  private

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def set_case
    head :not_found unless (@case = @mode.cases.find { |c| c.id == params[:id] })
  end
end
