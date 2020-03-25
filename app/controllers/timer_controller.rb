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
    @input_item = input_sampler.random_item
    CubeTrainer::Training::Input.new(mode: MODE, input_representation: @input_item.representation).save!
  end

  def store
    Result.from_input_and_partial(Input.find(params[:id]), PartialResult.new(params[:time_s]))
    redirect_to :index
  end
end
