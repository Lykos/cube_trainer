# frozen_string_literal: true

# Controller for showing inputs to the human and getting results.
class TrainerController < ApplicationController
  before_action :set_training_session
  before_action :set_cached_case_case_keys
  before_action :set_cached_cases

  # GET /api/trainer/1/random_case
  def random_case
    picked_case = @training_session.random_case(@cached_cases)
    render json: picked_case.to_simple
  end

  private

  def set_cached_cases
    @cached_cases = @training_session.cases&.select do |c|
      @cached_case_case_keys.include?(c.case_key)
    end || []
  end

  def set_cached_case_case_keys
    @cached_case_case_keys = params[:cached_case_keys] || []
  end

  def set_training_session
    @training_session = current_user.training_sessions.find_by(id: params[:training_session_id])
    head :not_found unless @training_session
  end
end
