class ResultsController < ApplicationController
  before_action :get_mode
  before_action :set_input, only: [:show, :destroy]
  before_action :check_owner_is_current_user

  # GET /modes
  # GET /modes.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json do
        logger.info "Doing JAYSON"
        render json: @mode.inputs.select(&:result).map(&:to_simple_result), status: :ok
      end
    end
  end

  # GET /modes/1
  # GET /modes/1.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @input.to_simple_result, status: :ok }
    end
  end

  def destroy
    @input.destroy
    head :no_content
  end

  private

  def set_input
    @input = Input.find(params[:id])
  end

  def get_mode
    @mode ||= Mode.find(params[:mode_id])
  end

  def get_owner
    get_mode.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params.require(:mode).permit(:name, :known, :mode_type, :show_input_mode, :buffer, :goal_badness, :cube_size)
  end
end
