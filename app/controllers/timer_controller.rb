# frozen_string_literal: true

require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'ostruct'

# Controller for showing inputs to the human and getting results.
class TimerController < ApplicationController
  def index
    @results = current_user.results.where(mode: mode.legacy_mode)
  end

  def next_input
    results_model = CubeTrainer::Training::ResultsModel.new(mode.legacy_mode, current_user)
    input_sampler = mode.generator.input_sampler(results_model)
    @results = current_user.results.where(mode: mode.legacy_mode)
    logger.info(@results.length)
    @input_item = input_sampler.random_item
    @input =
      current_user.inputs.new(
        mode: mode.legacy_mode, input_representation: @input_item.representation
      )
    @input.save!
    response = {id: @input.id, inputRepresentation: @input_item.representation.to_s}
    render json: response, status: :ok
  end

  def delete
    current_user.results.find(params[:id]).destroy!
    redirect_to '/timer/index'
  end

  def drop_input
    @input = current_user.inputs.find(params[:id])
    @input.destroy!
  end

  def stop
    @input = current_user.inputs.find(params[:id])
    partial_result = CubeTrainer::Training::PartialResult.new(params[:time_s])
    current_user.results.from_input_and_partial(@input, partial_result).save!
    @input.destroy!
  end

  private

  def mode
    @mode ||= current_user.modes.find(params[:mode_id])
  end
end
