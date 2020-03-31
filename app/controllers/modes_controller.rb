class ModesController < ApplicationController
  before_action :set_mode, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_is_current_user, only: [:show, :edit, :update, :destroy]

  # GET /modes
  # GET /modes.json
  def index
    @modes = current_user.modes
  end

  # GET /modes/1
  # GET /modes/1.json
  def show
  end

  # GET /modes/new
  def new
    @mode = current_user.modes.new
  end

  # GET /modes/1/edit
  def edit
  end

  # POST /modes
  # POST /modes.json
  def create
    @mode = current_user.modes.new(mode_params)

    respond_to do |format|
      if @mode.save
        format.html { redirect_to @mode, notice: 'Mode was successfully created.' }
        format.json { render :show, status: :created, location: @mode }
      else
        format.html { render :new }
        format.json { render json: @mode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /modes/1
  # PATCH/PUT /modes/1.json
  def update
    respond_to do |format|
      if @mode.update(mode_params)
        format.html { redirect_to @mode, notice: 'Mode was successfully updated.' }
        format.json { render :show, status: :ok, location: @mode }
      else
        format.html { render :edit }
        format.json { render json: @mode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /modes/1
  # DELETE /modes/1.json
  def destroy
    @mode.destroy
    respond_to do |format|
      format.html { redirect_to modes_url, notice: 'Mode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mode
    get_mode
  end

  def get_mode
    @mode ||= Mode.find(params[:id])
  end

  def get_owner
    get_mode.user
  end

  # Only allow a list of trusted parameters through.
  def mode_params
    params.require(:mode).permit(:name, :known, :type, :show_input_mode, :buffer, :goal_badness)
  end
end
