require 'net/http'

class CubeImagesController < ApplicationController
  # Get /trainer/1/cube_images/1.jpg
  def show
    @input = mode.inputs.find(params[:input_id])
    # TODO Make this efficient
    input_item = @mode.generator.input_items.find { |i| i.representation == @input.input_representation }
    unless input_item
      head :not_found
      return
    end
    unless input_item.cube_state
      head :unprocessable_entity
      return
    end

    send_data cube_visualizer.fetch(input_item.cube_state), type: 'image/jpg', disposition: 'inline'
  end

  private

  FORMAT = :jpg

  class CacheWrapper
    def [](key)
      Rails.cache.read(key)
    end

    def []=(key, value)
      Rails.cache.write(key, value)
    end
  end

  def cube_visualizer
    CubeTrainer::Anki::CubeVisualizer.new(
      fetcher: Net::HTTP, sch: @mode.color_scheme, cache: CacheWrapper.new, fmt: FORMAT, checker: checker
    )
  end

  def mode
    @mode ||= current_user.modes.find(params[:mode_id])
  end

  def checker
    CubeTrainer::Anki::ImageChecker.new(FORMAT)
  end
end
