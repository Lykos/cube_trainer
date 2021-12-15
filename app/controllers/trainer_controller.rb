# frozen_string_literal: true

# Controller for showing inputs to the human and getting results.
class TrainerController < ApplicationController
  before_action :set_mode
  before_action :set_input, only: %i[destroy stop]
  before_action :check_partial_result_param, only: [:stop]
  before_action :set_partial_result, only: [:stop]

  # GET /api/trainer/1/random_case
  def random_case
    picked_case = @mode.random_case(cached_cases)
    render json: picked_case.to_simple.merge!(hints: @mode.hints(picked_case))
  end

  private

  def cached_cases
    @cached_cases ||= @mode.cases.select { |c| cached_case_representations.include?(c.representation) }
  end

  def cached_case_representations
    @cached_case_representations ||= params[:cached_case_representations] || []
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end
end
