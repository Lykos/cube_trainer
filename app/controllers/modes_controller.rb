class ModesController < ApplicationController
  before_action :get_mode, only: [:show, :edit, :update, :destroy]
  before_action :check_current_user_owns, only: [:show, :edit, :update, :destroy]

  # GET /mode_types.json
  def types
    render json:
             [
               {
                 name: :corner_3twists,
                 show_input_modes: Mode::SHOW_INPUT_MODES,
                 has_buffer: true,
                 default_cube_size: 3,
                 has_goal_badness: true
               }
             ]
  end

  # GET /modes
  # GET /modes.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: current_user.modes }
    end
  end

  # GET /modes/1
  # GET /modes/1.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @mode }
    end
  end

  # GET /modes/new
  def new
    @mode = current_user.modes.new
    respond_to do |format|
      format.html { render 'application/empty' }
    end
  end

  # GET /modes/1/edit
  def edit
    respond_to do |format|
      format.html { render 'application/empty' }
    end
  end

  # POST /modes.json
  def create
    @mode = current_user.modes.new(mode_params)

    if @mode.save
      render json: @mode, status: :created
    else
      render json: @mode.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /modes/1.json
  def update
    respond_to do |format|
      if @mode.update(mode_params)
        render :show, location: @mode
      else
        render json: @mode.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /modes/1.json
  def destroy
    @mode.destroy
    respond_to do |format|
      head :no_content
    end
  end

  private

  def get_mode
    @mode ||= Mode.find(params[:id])
  end

  def get_owner
    get_mode.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params.require(:mode).permit(:name, :known, :mode_type, :show_input_mode, :buffer, :goal_badness, :cube_size)
  end
end
