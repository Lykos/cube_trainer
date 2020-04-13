class ModeTypesController < ApplicationController
  # GET /mode_types.json
  def index
    render json: ModeType::ALL.map { |m| m.to_simple }
  end
end
