# frozen_string_literal: true

require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'ostruct'

# Controller for showing inputs to the human and getting results.
class TrainerController < ApplicationController
  def index
    render 'application/empty'
  end

  # POST /trainer/1/inputs
  def create
    results_model = CubeTrainer::Training::ResultsModel.new(mode)
    input_sampler = mode.generator.input_sampler(results_model)
    @input_item = input_sampler.random_item
    @input = mode.inputs.new(input_representation: @input_item.representation)
    @input.save!
    response = {id: @input.id, inputRepresentation: @input_item.representation.to_s}
    render json: response, status: :ok
  end

  # DELETE /trainer/1/inputs/1
  def destroy
    @input = mode.inputs.find(params[:id])
    @input.destroy!
  end

  # POST /trainer/1/inputs/1
  def stop
    @input = mode.inputs.find(params[:id])
    partial_result = CubeTrainer::Training::PartialResult.new(params[:time_s])
    Result.from_input_and_partial(@input, partial_result).save!
  end

  private

  def mode
    @mode ||= current_user.modes.find(params[:mode_id])
  end
end
