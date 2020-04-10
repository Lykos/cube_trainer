# frozen_string_literal: true

require 'cube_trainer/training/commutator_options'
require 'ostruct'

# Controller for showing inputs to the human and getting results.
class TrainerController < ApplicationController
  before_action :set_mode
  before_action :set_input, only: [:destroy, :stop]

  def index
    render 'application/empty'
  end

  # POST /trainer/1/inputs
  def create
    input_sampler = @mode.generator.input_sampler(@mode)
    input_item = input_sampler.random_item
    input = @mode.inputs.new(input_representation: input_item.representation)
    if input.save
      response = {id: input.id, inputRepresentation: input_item.representation.to_s}
      render json: response, status: :created
    else
      render json: input.errors, status: :unprocessable_entity
    end
  end

  # DELETE /trainer/1/inputs/1
  def destroy
    if @input.destroy
      head :no_content
    else
      render json: @input.errors, status: :unprocessable_entity
    end
  end

  # POST /trainer/1/inputs/1
  def stop
    p partial_result
    result = Result.from_input_and_partial(@input, partial_result)
    if result.save
      head :created
    else
      render json: p(result.errors), status: :unprocessable_entity      
    end
  end

  private

  def set_input
    head :not_found unless @input = @mode.inputs.find_by(id: params[:id])
  end

  def set_mode
    head :not_found unless @mode = current_user.modes.find_by(id: params[:mode_id])
  end

  def partial_result_params
    params.require(:partial_result).permit(:time_s, :failed_attempts, :word, :success, :num_hints)
  end

  def partial_result
    # TODO Get this from the hash.
    CubeTrainer::Training::PartialResult.new(partial_result_params[:time_s])
  end
end
