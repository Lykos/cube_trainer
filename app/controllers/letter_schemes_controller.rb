# frozen_string_literal: true

require 'twisty_puzzles'

# Controller for letter schemes the user created.
class LetterSchemesController < ApplicationController
  before_action :check_no_existing_letter_scheme, only: %i[create]
  before_action :set_new_letter_scheme, only: %i[create]
  before_action :set_letter_scheme, only: %i[show update destroy]

  # GET /api/letter_scheme
  def show
    render json: @letter_scheme.to_simple
  end

  # POST /api/letter_scheme
  def create
    if !@letter_scheme.valid?
      render json: @letter_scheme.errors, status: :bad_request
    elsif @letter_scheme.save
      render json: @letter_scheme, status: :created
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/letter_scheme
  def update
    if @letter_scheme.update(letter_scheme_params)
      render json: @letter_scheme, status: :ok
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/letter_scheme
  def destroy
    if @letter_scheme.destroy
      head :no_content
    else
      render json: @letter_scheme.errors, status: :unprocessable_entity
    end
  end

  private

  def check_no_existing_letter_scheme
    head :unprocessable_entity if current_user.letter_scheme
  end

  def set_new_letter_scheme
    @letter_scheme = LetterScheme.new(letter_scheme_params)
    @letter_scheme.user = current_user
  end

  def set_letter_scheme
    head :not_found unless (@letter_scheme = current_user.letter_scheme)
  end

  # Only allow a list of trusted parameters through.
  def letter_scheme_params
    fixed_params = params
                   .require(:letter_scheme)
                   .permit(mappings: [:letter, { part: :key }])
    fixed_params[:mappings].each { |m| m[:part] = m[:part][:key] }
    fixed_params[:letter_scheme_mappings_attributes] = fixed_params[:mappings]
    fixed_params.delete(:mappings)
    fixed_params
  end
end
