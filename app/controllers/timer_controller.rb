require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'ostruct'

class TimerController < ApplicationController
  OPTIONS = begin
              options = CubeTrainer::Training::CommutatorOptions.default_options
              options.commutator_info = CubeTrainer::Training::CommutatorOptions::COMMUTATOR_TYPES[:corners] || raise
              options
            end
  MODE = :ulb_corner_commutators

  def index
    generator = OPTIONS.commutator_info.generator_class.new(OPTIONS)
    results_model = CubeTrainer::Training::ResultsModel.new(MODE)
    input_sampler = generator.input_sampler(results_model)
    @results = results_model.results
    @input_item = input_sampler.random_item
    @input = CubeTrainer::Training::Input.new(mode: MODE, input_representation: @input_item.representation)
    @input.save!
  end

  def post
    @input = CubeTrainer::Training::Input.find(params[:id])
    partial_result = CubeTrainer::Training::PartialResult.new(params[:time_s])
    CubeTrainer::Training::Result.from_input_and_partial(@input, partial_result)
    @input.destroy!
    redirect_to '/timer/index'
  end
end
