# frozen_string_literal: true

# Controller that shows the static index for all interesting routes.
class IndexController < ApplicationController
  # We skip authorization since this doesn't serve any private data.
  # Also, it needs to be public as the whole frontend including the login flow is served like this.
  skip_before_action :check_authorized, only: %i[index]
  skip_before_action :check_current_user_can_read, only: %i[index]
  skip_before_action :check_current_user_can_write, only: %i[index]

  def index
    render file: Rails.root.join('public/index.html')
  end
end
