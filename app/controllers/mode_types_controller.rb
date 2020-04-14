class ModeTypesController < ApplicationController
  before_action :set_mode_type, only: [:show]

  # GET /mode_types
  # GET /mode_types.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: ModeType::ALL.map { |m| m.to_simple } }
    end
  end

  # GET /mode_types/mode_created
  # GET /mode_types/mode_created.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @mode_type.to_simple }
    end
  end

  private

  def set_mode_type
    head :not_found unless @mode_type = ModeType.find_by_key(params[:id])
  end
end
