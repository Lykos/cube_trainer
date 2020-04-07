class CubeImagesController < ApplicationController
  # Get /trainer/1/cube_images/1.jpg
  def show
    @input = mode.inputs.find(params[:id])
    @input.input_representation
  end

  private

  def mode
    @mode ||= current_user.modes.find(params[:mode_id])
  end
end
