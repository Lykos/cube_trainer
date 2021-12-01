# frozen_string_literal: true

# Controller for showing inputs to the human and getting results.
class TrainerController < ApplicationController
  before_action :set_mode
  before_action :set_input, only: %i[destroy stop]
  before_action :check_partial_result_param, only: [:stop]
  before_action :set_partial_result, only: [:stop]

  # POST /api/trainer/1/inputs
  def create
    input_item = @mode.random_item(cached_inputs)
    input = @mode.inputs.new(input_representation: input_item.representation)
    if input.save
      response = {
        id: input.id,
        representation: @mode.maybe_apply_letter_scheme(input_item.representation).to_s,
        setup: @mode.setup(input).to_s,
        hints: @mode.hints(input).map(&:to_s)
      }
      render json: response, status: :created
    else
      render json: input.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/trainer/1/inputs/1
  def destroy
    if @input.destroy
      head :no_content
    else
      render json: @input.errors, status: :unprocessable_entity
    end
  end

  # POST /api/trainer/1/inputs/1
  def stop
    # TODO: What if a result already exists?
    result = Result.from_input_and_partial(@input, @partial_result)
    if !result.valid?
      render json: result.errors, status: :bad_request
    elsif result.save
      head(:created)
    else
      render json: result.errors, status: :unprocessable_entity
    end
  end

  private

  def cached_inputs
    @cached_inputs ||= @mode.inputs.where(id: cached_input_ids).to_a
  end

  def cached_input_ids
    @cached_input_ids ||= params[:cached_input_ids] || []
  end

  def set_input
    head :not_found unless (@input = @mode.inputs.find_by(id: params[:id]))
  end

  def set_mode
    head :not_found unless (@mode = current_user.modes.find_by(id: params[:mode_id]))
  end

  def owner
    mode&.user
  end

  def partial_result_params
    params.require(:partial_result).permit(:time_s, :failed_attempts, :word, :success, :num_hints)
  end

  def check_partial_result_param
    head(:bad_request) unless params[:partial_result]
  end

  def set_partial_result
    @partial_result = PartialResult.new(partial_result_params)
    head(:bad_request, @partial_result.errors) unless @partial_result.valid?
  end
end
