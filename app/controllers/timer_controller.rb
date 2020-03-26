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
    @results = CubeTrainer::Training::Result.where(mode: MODE)
  end

  def start
    generator = OPTIONS.commutator_info.generator_class.new(OPTIONS)
    results_model = CubeTrainer::Training::ResultsModel.new(MODE)
    input_sampler = generator.input_sampler(results_model)
    @results = CubeTrainer::Training::Result.where(mode: MODE)
    logger.info(@results.length)
    @input_item = input_sampler.random_item
    @input =
      CubeTrainer::Training::Input.new(
        mode: MODE, input_representation: @input_item.representation
      )
    @input.save!
  end

  def delete
    CubeTrainer::Training::Result.find(params[:id]).destroy!
    redirect_to('/timer/index')
  end

  def stop
    @input = CubeTrainer::Training::Input.find(params[:id])
    partial_result = CubeTrainer::Training::PartialResult.new(params[:time_s])
    CubeTrainer::Training::Result.from_input_and_partial(@input, partial_result).save!
    @input.destroy!
    redirect_to('/timer/index')
  end
end
