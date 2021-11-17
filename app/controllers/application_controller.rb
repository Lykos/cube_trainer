# frozen_string_literal: true

# Base class for all controllers. Handles things like checking for login.
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery unless: -> { request.format.json? }
  before_action :authenticate_user!, unless: -> { devise_controller? }

  def authenticate_user!
    super
    head :unauthorized unless current_user.admin_confirmed
  end
end
