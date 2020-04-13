class ModeTypesController < ApplicationController
  # GET /mode_types.json
  def index
    render json: Mode::MODE_TYPES.map { |m| m.to_simple }
  end
end
