# frozen_string_literal: true

require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'ostruct'

# Controller for showing inputs to the human and getting results.
class TimerController < ApplicationController
  OPTIONS =
    begin
      options = CubeTrainer::Training::CommutatorOptions.default_options
      options.commutator_info =
        CubeTrainer::Training::CommutatorOptions::COMMUTATOR_TYPES[:corners] || raise
      options
    end
  MODE = :ulb_corner_commutators

  def index
    @results = current_user.results.where(mode: MODE)
  end

  def next_input
    generator = OPTIONS.commutator_info.generator_class.new(OPTIONS)
    results_model = CubeTrainer::Training::ResultsModel.new(MODE, current_user)
    input_sampler = generator.input_sampler(results_model)
    @results = current_user.results.where(mode: MODE)
    logger.info(@results.length)
    @input_item = input_sampler.random_item
    @input =
      current_user.inputs.new(
        mode: MODE, input_representation: @input_item.representation
      )
    @input.save!
    response = {id: @input.id, inputRepresentation: @input_item.representation.to_s}
    render json: response, status: :ok
  end

  def delete
    current_user.results.find(params[:id]).destroy!
    redirect_to('/timer/index')
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
end
