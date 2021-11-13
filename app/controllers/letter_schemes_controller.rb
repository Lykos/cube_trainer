# frozen_string_literal: true

require 'twisty_puzzles'

# Controller for letter schemes the user created.
class LetterSchemesController < ApplicationController
  before_action :set_letter_scheme, only: %i[show update destroy]
  before_action :check_current_user_owns, only: %i[show update destroy]

  def name_exists_for_user?
    render json: current_user.letter_schemes.exists?(name: params[:letter_scheme_name]), status: :ok
  end

  # GET /api/letter_schemes
  # GET /api/letter_schemes.json
  def index
    respond_to do |format|
      format.json { render json: current_user.letter_schemes }
    end
  end

  # GET /api/letter_schemes/1
  # GET /api/letter_schemes/1.json
  def show
    respond_to do |format|
      format.json { render json: @letter_scheme }
    end
  end

  # POST /api/letter_schemes.json
  def create
    @letter_scheme = current_user.letter_schemes.new(letter_scheme_params)

    if !@letter_scheme.valid?
      render json: @letter_scheme, status: :bad_request
    elsif @letter_scheme.save
      render json: @letter_scheme, status: :created
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/letter_schemes/1.json
  def update
    if @letter_scheme.update(letter_scheme_params)
      render json: @letter_scheme, status: :ok
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/letter_schemes/1.json
  def destroy
    if @letter_scheme.destroy
      head :no_content
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  private

  def set_letter_scheme
    head :not_found unless (@letter_scheme = LetterScheme.find_by(id: params[:id]))
  end

  def owner
    @letter_scheme.user
  end

  PERMITTED_FACE_PARAMS =
    TwistyPuzzles::CubeConstants::FACE_SYMBOLS.map do |f|
      f.to_s.downcase.to_sym
    end

  # Only allow a list of trusted parameters through.
  def letter_scheme_params
    params
      .require(:letter_scheme)
      .permit(:name, *PERMITTED_FACE_PARAMS)
  end
end
