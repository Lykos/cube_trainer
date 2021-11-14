# frozen_string_literal: true

require 'twisty_puzzles'

# Controller for letter schemes the user created.
class LetterSchemesController < ApplicationController
  prepend_before_action :set_new_letter_scheme, only: %i[create]
  prepend_before_action :set_letter_scheme, only: %i[show update destroy]

  # GET /api/letter_scheme.json
  def show
    render json: @letter_scheme.to_simple
  end

  # POST /api/letter_scheme.json
  def create
    if !@letter_scheme.valid?
      render json: @letter_scheme, status: :bad_request
    elsif @letter_scheme.save
      render json: @letter_scheme, status: :created
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/letter_scheme.json
  def update
    if @letter_scheme.update(letter_scheme_params)
      render json: @letter_scheme, status: :ok
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/letter_scheme.json
  def destroy
    if @letter_scheme.destroy
      head :no_content
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  private

  def set_new_letter_scheme
    @letter_scheme = LetterScheme.new(letter_scheme_params)
    @letter_scheme.user = current_user
  end

  def set_letter_scheme
    head :not_found unless (@letter_scheme = current_user.letter_scheme)
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
