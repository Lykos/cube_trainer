# frozen_string_literal: true

require 'twisty_puzzles'

# Controller for color schemes the user created.
class ColorSchemesController < ApplicationController
  before_action :check_no_existing_color_scheme, only: %i[create]
  before_action :set_new_color_scheme, only: %i[create]
  before_action :set_color_scheme, only: %i[show update destroy]

  # GET /api/color_schemes/1.json
  def show
    render json: @color_scheme
  end

  # POST /api/color_schemes.json
  def create
    if !@color_scheme.valid?
      render json: @color_scheme.errors, status: :bad_request
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

  def check_no_existing_color_scheme
    head :unprocessable_entity if current_user.color_scheme
  end

  def set_color_scheme
    head :not_found unless (@color_scheme = current_user.color_scheme)
  end

  def set_new_color_scheme
    @color_scheme = ColorScheme.new(color_u: color_scheme_params[:color_u].downcase,
                                    color_f: color_scheme_params[:color_f].downcase)
    @color_scheme.user = current_user
  end

  # Only allow a list of trusted parameters through.
  def color_scheme_params
    params
      .require(:color_scheme)
      .permit(:color_u, :color_f)
  end
end
