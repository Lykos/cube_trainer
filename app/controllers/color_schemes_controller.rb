require 'twisty_puzzles'

class ColorSchemesController < ApplicationController
  before_action :set_color_scheme, only: %i[show update destroy]
  before_action :check_current_user_owns, only: %i[show update destroy]

  def name_exists_for_user?
    render json: current_user.color_schemes.exists?(name: params[:color_scheme_name]), status: :ok
  end

  # GET /api/color_schemes
  # GET /api/color_schemes.json
  def index
    respond_to do |format|
      format.json { render json: current_user.color_schemes }
    end
  end

  # GET /api/color_schemes/1
  # GET /api/color_schemes/1.json
  def show
    respond_to do |format|
      format.json { render json: @color_scheme }
    end
  end

  # POST /api/color_schemes.json
  def create
    @color_scheme = current_user.color_schemes.new(color_scheme_params)

    if !@color_scheme.valid?
      render json: @color_scheme, status: :bad_request
    elsif @color_scheme.save
      render json: @color_scheme, status: :created
    else
      render json: @color_scheme.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/color_schemes/1.json
  def update
    if @color_scheme.update(color_scheme_params)
      render json: @color_scheme, status: :ok
    else
      render json: @color_scheme.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/color_schemes/1.json
  def destroy
    if @color_scheme.destroy
      head :no_content
    else
      render json: @color_scheme.errors, status: :unprocessable_entity
    end
  end

  private

  def set_color_scheme
    head :not_found unless (@color_scheme = ColorScheme.find_by(id: params[:id]))
  end

  def owner
    @color_scheme.user
  end

  PERMITTED_FACE_PARAMS = TwistyPuzzles::CubeConstants::FACE_SYMBOLS.map { |f| f.to_s.downcase.to_sym }

  # Only allow a list of trusted parameters through.
  def color_scheme_params
    params
      .require(:color_scheme)
      .permit(:name, *PERMITTED_FACE_PARAMS)
  end
end
