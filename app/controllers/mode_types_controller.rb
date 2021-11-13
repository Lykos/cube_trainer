# frozen_string_literal: true

# Controller that allows retrieval of mode types.
# Mode types are basic templates which users use to create their training modes.
class ModeTypesController < ApplicationController
  before_action :set_mode_type, only: [:show]

  # GET /api/mode_types.json
  def index
    respond_to do |format|
      format.json { render json: ModeType.all.map(&:to_simple) }
    end
  end

  # GET /api/mode_types/1.json
  def show
    respond_to do |format|
      format.json { render json: @mode_type.to_simple }
    end
  end

  private

  def set_mode_type
    head :not_found unless (@mode_type = ModeType.find_by(key: params[:id]))
  end
end
