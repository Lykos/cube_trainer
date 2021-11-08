# frozen_string_literal: true

# Controller that shows the static index for all interesting routes.
class IndexController < ApplicationController
  def index
    render file: Rails.root.join('public/index.html')
  end
end
