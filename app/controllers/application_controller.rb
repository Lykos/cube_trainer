# frozen_string_literal: true

# Base class for all controllers. Handles things like checking for login.
class ApplicationController < ActionController::Base
        include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery unless: -> { request.format.json? }
  before_action :check_authorized
  before_action :check_current_user_can_read
  before_action :check_current_user_can_write, except: %i[show index]

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def admin_logged_in?
    current_user&.admin?
  end

  def check_authorized
    render json: {}, status: :unauthorized unless logged_in?
  end

  def check_authorized_as_admin
    render json: {}, status: :unauthorized unless admin_logged_in?
  end

  # Checks that current user can write something.
  # In order to not allow reverse engineering, we have to return not_found in all such cases.
  def check_current_user_can_write
    head :not_found unless owner == current_user || admin_logged_in?
  end

  # Checks that the user is the current user.
  # In order to not allow reverse engineering, we have to return not_found in all such cases.
  def check_current_user_can_read
    head :not_found unless owner == current_user || admin_logged_in?
  end
end
